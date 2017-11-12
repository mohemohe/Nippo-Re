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
