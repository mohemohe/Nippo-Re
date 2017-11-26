import $ from 'jquery';
import axios from 'axios';
import pako from "pako";
import aesjs from 'aes-js';
import sha256 from 'js-sha256';
import { EventWorker } from '../eventWorker';
import { IndexedDb } from "../indexedDb";


axios.defaults.withCredentials = true;
axios.defaults.headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  'X-CSRF-Token': $("meta[name='csrf-token']").attr('content'),
};

export function apiLogin(username, password) {
  axios.post('/auth/login', {
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
  EventWorker.event.trigger('apiLogout:done');
}

export function apiSignup(username, password) {
  axios.post('/auth/signup', {
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
  const authInfo = JSON.parse(localStorage.auth_info);

  return axios.post('/auth/refresh-token', authInfo).then(res => {
    return res.data;
  }).then(data => {
    if(data.access_token) {
      localStorage.auth_info = JSON.stringify(data);
    } else {
      throw new Error();
    }
    EventWorker.event.trigger('apiRefreshToken:done');
    return data;
  }).catch(e => {
    console.error(e);
    EventWorker.event.trigger('apiRefreshToken:error');
    return null;
  });
}

export function apiGetUserName() {
  const accessToken = JSON.parse(localStorage.auth_info).access_token;

  axios.get('/auth/me', {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
  }).then(res => {
    return res.data;
  }).then(data => {
    localStorage.username = data.username;
    EventWorker.event.trigger('apiGetUserName:done', data.username);
  }).catch(e => {
    console.error(e);
  });
}

export function syncImportDB(e2eEncPassword) {
  apiRefreshToken().then(() => {
    return axios.get('/sync', {
      headers: {
        'Authorization': `Bearer ${JSON.parse(localStorage.auth_info).access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    if(data.nippo) {
      return data.nippo;
    } else {
      throw new Error();
    }
  }).then(encString => {
    if(e2eEncPassword && e2eEncPassword != null) {
      const key = sha256.array(e2eEncPassword);
      const encryptedBytes = aesjs.utils.hex.toBytes(encString);
      const aesCtr = new aesjs.ModeOfOperation.ctr(key, new aesjs.Counter(e2eEncPassword.length));
      const decryptedBytes = aesCtr.decrypt(encryptedBytes);
      return aesjs.utils.utf8.fromBytes(decryptedBytes);
    } else {
      return encString;
    }
  }).then(decString => {
    return pako.inflate(decString, { to: 'string' });
  }).then(importText => {
    return IndexedDb.import(importText);
  }).then(result => {
    if (result) {
      EventWorker.event.trigger('syncImportDB:done');
    } else {
      EventWorker.event.trigger('syncImportDB:error');
    }
  }).catch(e => {
    EventWorker.event.trigger('syncImportDB:error');
  });
}

export function syncExportDB(e2eEncPassword) {
  apiRefreshToken().then(() => {
    return IndexedDb.export();
  }).then(jsonString => {
    return pako.deflate(jsonString, { to: 'string' });
  }).then(gzipString => {
    if(e2eEncPassword && e2eEncPassword != null) {
      const key = sha256.array(e2eEncPassword);
      const textBytes = aesjs.utils.utf8.toBytes(gzipString);
      const aesCtr = new aesjs.ModeOfOperation.ctr(key, new aesjs.Counter(e2eEncPassword.length));
      const encryptedBytes = aesCtr.encrypt(textBytes);
      return aesjs.utils.hex.fromBytes(encryptedBytes);
    } else {
      return gzipString;
    }
  }).then(exportText => {
    return axios.post('/sync', {
      nippo: exportText,
    }, {
      headers: {
        'Authorization': `Bearer ${JSON.parse(localStorage.auth_info).access_token}`,
      },
    });
  }).then(res => {
    return res.data;
  }).then(data => {
    if(data.username) {
      EventWorker.event.trigger('syncExportDB:done');
    } else {
      throw new Error();
    }
  }).catch(e => {
    console.error(e);
    EventWorker.event.trigger('syncExportDB:error');
  });
}


