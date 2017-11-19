import { EventWorker } from '../eventWorker';
import { IndexedDb } from '../indexedDb';

export function nippoSave(args) {
  let dbObj = {
    title: args.title,
    date: args.date.split('-').join(''),
    body: args.body,
    updated_at: new Date()
  };
  if(args.id !== null) {
    dbObj.id = args.id;
  }

  IndexedDb.dexie.nippo.put(dbObj).then((result) => {
    EventWorker.event.trigger('saveNippo:done', result);
  }).catch(() => {
    EventWorker.event.trigger('saveNippo:error');
  });
}

export function nippoList(offset, limit) {
  IndexedDb.dexie.nippo.orderBy('date').reverse().offset(offset).limit(limit).toArray().then((result) => {
    EventWorker.event.trigger('listNippo:done', result);
  }).catch(() => {
    EventWorker.event.trigger('listNippo:error');
  });
}

export function nippoGet(id) {
  IndexedDb.dexie.nippo.get(id).then((result) => {
    EventWorker.event.trigger('getNippo:done', result);
  }).catch(() => {
    EventWorker.event.trigger('getNippo:error');
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
      EventWorker.event.trigger('importNippo:done');
    } else {
      EventWorker.event.trigger('importNippo:error');
    }
  }).catch(e => {
    EventWorker.event.trigger('importNippo:error');
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
      return EventWorker.event.trigger('exportNippo:error');
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
