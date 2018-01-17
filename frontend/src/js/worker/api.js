import $ from 'jquery';
import axios from 'axios';
import aesjs from 'aes-js';
import sha256 from 'js-sha256';
import moment from 'moment';
import { EventWorker } from '../eventWorker';
import { IndexedDb } from "../indexedDb";

axios.defaults.withCredentials = true;
axios.defaults.headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  'X-CSRF-Token': $("meta[name='csrf-token']").attr('content'),
};

function aes256ctrEncrypt(target, password) {
  const key = sha256.array(password);
  const textBytes = aesjs.utils.utf8.toBytes(target);
  const aesCtr = new aesjs.ModeOfOperation.ctr(key, new aesjs.Counter(password.length));
  const encryptedBytes = aesCtr.encrypt(textBytes);
  return aesjs.utils.hex.fromBytes(encryptedBytes);
}

function aes256ctrDecrypt(target, password) {
  const key = sha256.array(password);
  const encryptedBytes = aesjs.utils.hex.toBytes(target);
  const aesCtr = new aesjs.ModeOfOperation.ctr(key, new aesjs.Counter(password.length));
  const decryptedBytes = aesCtr.decrypt(encryptedBytes);
  return aesjs.utils.utf8.fromBytes(decryptedBytes);
}

export function apiLogin(username, password) {
  axios.post('/api/v2/auth/login', {
    username,
    password
  }).then(res => {
    return res.data;
  }).then(data => {
    if(data.access_token) {
      localStorage.auth_info = JSON.stringify(data);
      EventWorker.event.trigger('apiLogin:done', data);
      EventWorker.event.trigger('apiGetUserName:raise', data);
    } else {
      throw new Error();
    }
  }).catch(e => {
    EventWorker.event.trigger('apiLogin:error');
  });
}

export function apiLogout() {
  localStorage.removeItem('username');
  localStorage.removeItem('auth_info');
  localStorage.removeItem('lastTokenRefresh');

  EventWorker.event.trigger('apiLogout:done');
}

export function apiSignup(username, password) {
  axios.post('/api/v2/auth/signup', {
    username,
    password,
  }).then(res => {
    return res.data;
  }).then(data => {
    if (data.access_token) {
      localStorage.auth_info = JSON.stringify(data);
      EventWorker.event.trigger('apiSignup:done', data);
      EventWorker.event.trigger('apiLogin:done', data);
      EventWorker.event.trigger('apiGetUserName:raise', data);
    } else {
      throw new Error();
    }
  }).catch(e => {
    EventWorker.event.trigger('apiSignup:error', e);
  });
}

export function apiRefreshToken() {
  const lastTokenRefresh = localStorage.lastTokenRefresh;
  if(lastTokenRefresh) {
    const lastTokenRefreshDate = moment(new Date(parseInt(localStorage.lastTokenRefresh, 10)));
    const tokenExpire = lastTokenRefreshDate.add(5, 'm');

    const now = moment();
    const needToRefresh = now.isAfter(tokenExpire);
    console.log('need to refresh token:', needToRefresh);
    if (!needToRefresh) {
      EventWorker.event.trigger('apiRefreshToken:done');
      return Promise.resolve(JSON.parse(localStorage.auth_info));
    }
  }
  const authInfo = JSON.parse(localStorage.auth_info);

  return axios.post('/api/v2/auth/token/refresh', authInfo).then(res => {
    return res.data;
  }).then(data => {
    if(data.access_token) {
      localStorage.auth_info = JSON.stringify(data);
    } else {
      throw new Error();
    }

    localStorage.lastTokenRefresh = new Date().getTime();

    console.log('token refresh: success');
    EventWorker.event.trigger('apiRefreshToken:done');
    return data;
  }).catch(e => {
    console.log('token refresh: error');
    console.error(e);
    EventWorker.event.trigger('apiRefreshToken:error');
    return null;
  });
}

export function apiGetUserName() {
  apiRefreshToken().then(authInfo => {
    return axios.get('/api/v2/user', {
      headers: {
        'Authorization': `Bearer ${authInfo.access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    localStorage.username = data.username;
    EventWorker.event.trigger('apiGetUserName:done', data.username);
  }).catch(e => {
    console.error(e);
  });
}

export function updatePassword(password) {
  apiRefreshToken().then(authInfo => {
    return axios.post('/api/v2/user/password', {
      password,
    }, {
      headers: {
        'Authorization': `Bearer ${authInfo.access_token}`,
      },
    });
  }).then(res => {
    if (res.status === 200) {
      EventWorker.event.trigger('updatePassword:done');
    } else {
      EventWorker.event.trigger('updatePassword:error');
    }
  }).catch(e => {
    EventWorker.event.trigger('updatePassword:error');
  });
}

export function syncImportDB(e2eEncPassword) {
  apiRefreshToken().then(authInfo => {
    return axios.get('/api/v2/sync', {
      headers: {
        'Authorization': `Bearer ${authInfo.access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    if(data.result) {
      return data.result;
    } else {
      throw new Error();
    }
  }).then(nippos => {
    nippos.forEach(nippo => {
      if (nippo.isEncrypted) {
        nippo.title = aes256ctrDecrypt(nippo.title, e2eEncPassword);
        nippo.body = aes256ctrDecrypt(nippo.body, e2eEncPassword);
      }

      if (nippo.sharedPassword && nippo.sharedPassword !== '' && e2eEncPassword && e2eEncPassword !== '') {
        try {
          nippo.sharedPassword = aes256ctrDecrypt(nippo.sharedPassword, e2eEncPassword);
        } catch (e) {
          console.warn(e);
        }
      }
    });

    return nippos;
  }).then(nippos => {
    nippos.forEach(nippo => {
      nippo.id = nippo.nippoId;
      nippo.title = decodeURIComponent(nippo.title);
      nippo.body = decodeURIComponent(nippo.body);

      delete nippo.nippoId;
      delete nippo.isEncrypted;
      delete nippo.sharedTitle;
      delete nippo.sharedBody;
    });
    return nippos;
  }).then(nippos => {
    const importJson = {
      nippo: nippos,
    };
    return JSON.stringify(importJson);
  }).then(importText => {
    return IndexedDb.import(importText);
  }).then(result => {
    if (result) {
      localStorage.syncApiVersion = 3;
      EventWorker.event.trigger('syncImportDB:done');
    } else {
      EventWorker.event.trigger('syncImportDB:error');
    }
  }).catch(e => {
    console.error(e);
    EventWorker.event.trigger('syncImportDB:error');
  });
}

export function syncExportDB(e2eEncPassword) {
  let _authInfo;
  apiRefreshToken().then(authInfo => {
    _authInfo = authInfo;

    return IndexedDb.export();
  }).then(jsonString => {
    const json = JSON.parse(jsonString);
    json.nippos = json.nippo;
    delete json.nippo;
    return json;
  }).then(json => {
    json.nippos.forEach(n => {
      n.title = encodeURIComponent(n.title);
      n.body = encodeURIComponent(n.body);

      n.isShared = n.isShared || false;
      n.isEncrypted = false;
      if (n.isShared) {
        n.sharedTitle = n.title;
        n.sharedBody = n.body;
      }
    });
    return json;
  }).then(json => {
    if(e2eEncPassword && e2eEncPassword != null) {
      json.nippos.forEach(n => {
        n.title = aes256ctrEncrypt(n.title, e2eEncPassword);
        n.body = aes256ctrEncrypt(n.body, e2eEncPassword);
        n.isEncrypted = true;
      });
    }
    return json;
  }).then(json => {
    json.nippos.forEach(n => {
      n.nippoId = n.id;
      delete n.id;

      if (n.sharedTitle && n.sharedPassword && n.sharedPassword !== '') {
        n.sharedTitle = aes256ctrEncrypt(n.sharedTitle, n.sharedPassword);
      }
      if (n.sharedBody && n.sharedPassword && n.sharedPassword !== '') {
        n.sharedBody = aes256ctrEncrypt(n.sharedBody, n.sharedPassword);
      }
    });
    return json;
  }).then(json => {
    return axios.post('/api/v2/sync', {
      nippos: json.nippos,
    }, {
      headers: {
        'Authorization': `Bearer ${_authInfo.access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    if(data.status === 0) {
      localStorage.syncApiVersion = 3;
      EventWorker.event.trigger('syncExportDB:done');
    } else {
      throw new Error();
    }
  }).catch(e => {
    console.error(e);
    EventWorker.event.trigger('syncExportDB:error');
  });
}

export function updateRemoteNippo(nippoObj, e2eEncPassword) {
  let _authInfo;
  apiRefreshToken().then(authInfo => {
    _authInfo = authInfo;

    nippoObj.title = encodeURIComponent(nippoObj.title);
    nippoObj.body = encodeURIComponent(nippoObj.body);

    nippoObj.isShared = nippoObj.isShared || false;
    nippoObj.isEncrypted = false;
    if (nippoObj.isShared) {
      nippoObj.sharedTitle = nippoObj.title;
      nippoObj.sharedBody = nippoObj.body;
    }

    return nippoObj;
  }).then(nippoObj => {
    nippoObj.isEncrypted = false;
    if (e2eEncPassword && e2eEncPassword !== '') {
        nippoObj.title = aes256ctrEncrypt(nippoObj.title, e2eEncPassword);
        nippoObj.body = aes256ctrEncrypt(nippoObj.body, e2eEncPassword);
        nippoObj.isEncrypted = true;
    }
    return nippoObj;
  }).then(nippoObj => {
    if (nippoObj.sharedTitle && nippoObj.sharedPassword && nippoObj.sharedPassword !== '') {
      nippoObj.sharedTitle = aes256ctrEncrypt(nippoObj.sharedTitle, nippoObj.sharedPassword);
    }
    if (nippoObj.sharedBody && nippoObj.sharedPassword && nippoObj.sharedPassword !== '') {
      nippoObj.sharedBody = aes256ctrEncrypt(nippoObj.sharedBody, nippoObj.sharedPassword);
    }
    if (nippoObj.sharedPassword && nippoObj.sharedPassword !== '' && e2eEncPassword && e2eEncPassword !== '') {
      nippoObj.sharedPassword = aes256ctrEncrypt(nippoObj.sharedPassword, e2eEncPassword);
    }
    return nippoObj;
  }).then(nippoObj => {
    return axios.put(`/api/v2/sync/${nippoObj.id}`, {
      nippo: nippoObj,
    }, {
      headers: {
        'Authorization': `Bearer ${_authInfo.access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    if (data.status === 0) {
      EventWorker.event.trigger('updateRemoteNippo:done', data.result);
    } else {
      throw new Error();
    }
  }).catch(e => {
    console.error(e);
    EventWorker.event.trigger('updateRemoteNippo:error');
  });
}

export function deleteRemoteNippo(id) {
  apiRefreshToken().then(authInfo => {
    return axios.delete(`/api/v2/sync/${id}`, {
      headers: {
        'Authorization': `Bearer ${authInfo.access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    if(data.status && data.status === 0) {
      EventWorker.event.trigger('deleteRemoteNippo:done');
    } else {
      EventWorker.event.trigger('deleteRemoteNippo:error');
    }
  })
}

export function getSharedNippo(username, hash) {
  return axios.get(`/api/v2/share/${username}/${hash}`).then(res => {
    return res.data;
  }).then(data => {
    if (data.status === 0) {
      EventWorker.event.trigger('getSharedNippo:done', data.result);
    } else {
      throw new Error();
    }
  }).catch(e => {
    console.error(e);
    EventWorker.event.trigger('getSharedNippo:error');
  });
}
