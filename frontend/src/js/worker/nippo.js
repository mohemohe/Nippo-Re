import * as _ from 'lodash';
import { EventWorker } from '../eventWorker';
import { IndexedDb } from '../indexedDb';

export function nippoSave(args) {
  let dbObj = {
    title: args.title,
    date: args.date.split('-').join(''),
    body: args.body,
    isShared: args.isShared,
    sharedPassword: args.sharedPassword,
    updated_at: new Date()
  };
  if (args.id !== null) {
    dbObj.id = args.id;
  }
  if (args.sharedHash && args.sharedHash !== '') {
    dbObj.sharedHash = args.sharedHash;
  }

  IndexedDb.dexie.nippo.put(dbObj).then((id) => {
    console.log('onNippoSave:', id);
    EventWorker.event.trigger('nippoSave:done', id, dbObj);
  }).catch(() => {
    EventWorker.event.trigger('nippoSave:error');
  });
}

export function nippoUpdate(args) {
  const id = args.id;
  delete args.id;

  IndexedDb.dexie.nippo.get(id).then((result) => {
    return result;
  }).then(nippo => {
    return _.merge(nippo, args);
  }).then(updateObj => {
    return IndexedDb.dexie.nippo.update(id, updateObj);
  }).catch((e) => {
    console.error(e);
  });
}

export function nippoList(offset, limit) {
  IndexedDb.dexie.nippo.orderBy('date').reverse().offset(offset).limit(limit).toArray().then((result) => {
    EventWorker.event.trigger('nippoList:done', result);
  }).catch(() => {
    EventWorker.event.trigger('nippoList:error');
  });
}

export function nippoSearch(keyword, offset, limit) {
  if (keyword === "" || keyword === '　') {
    return nippoList(offset, limit);
  }

  const replacedKeyword = keyword.replace(/　/g, ' ');
  const keywordArray = replacedKeyword.split(' ').filter(value => {
    return value !== '';
  });

  const isContain = (ary, target) => {
    const resultArray = ary.map(value => {
       return target.indexOf(value) > -1;
    });

    return resultArray.indexOf(false) === -1;
  };

  IndexedDb.dexie.nippo.orderBy('date').reverse().filter(_ => {
    return isContain(keywordArray, `${_.title} ${_.body}`);
  }).offset(offset).limit(limit).toArray().then((result) => {
    EventWorker.event.trigger('nippoList:done', result);
  }).catch(() => {
    EventWorker.event.trigger('nippoList:error');
  });
}

export function nippoGet(id) {
  IndexedDb.dexie.nippo.get(id).then((result) => {
    EventWorker.event.trigger('nippoGet:done', result);
  }).catch((e) => {
    console.error(e);
    EventWorker.event.trigger('nippoGet:error');
  });
}

let input;
export function nippoImport() {
  loadFile().then(string => {
    JSON.parse(string);
    return string;
  }).then(jsonString => {
    return IndexedDb.import(jsonString);
  }).then(result => {
    if (result) {
      EventWorker.event.trigger('nippoImport:done');
    } else {
      EventWorker.event.trigger('nippoImport:error');
    }
  }).catch(e => {
    EventWorker.event.trigger('nippoImport:error');
  });
}

function loadFile() {
  return new Promise(resolve => {
    if(!input) {
      input = document.createElement("input");
      document.body.appendChild(input);
      input.style.display = 'none';
      input.type = 'file';
      input.addEventListener('change', event => {
        const file = event.target.files;
        const reader = new FileReader();
        reader.readAsText(file[0]);
        reader.onload = () => {
          resolve(reader.result);
        };
        document.body.removeChild(input);
      }, false);
    }
    input.click();
  })
}

export function nippoExport() {
  IndexedDb.export().then(jsonString => {
    if(jsonString === null) {
      return EventWorker.event.trigger('nippoExport:error');
    }

    const blob = new Blob([ jsonString ], { 'type' : 'text/plain' });
    const filename = 'nippore.json';

    if (window.navigator.msSaveBlob) {
      window.navigator.msSaveBlob(blob, filename);
    } else {
      const objectURL = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      document.body.appendChild(link);
      link.href = objectURL;
      link.download = filename;
      link.click();
      document.body.removeChild(link);
    }
  });
}
