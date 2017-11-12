import Dexie from 'dexie';

let db;

export class IndexedDb {
  static initialize() {
    if(!db) {
      db = new Dexie("NippoRe");
      db.version(1).stores({
        nippo: '++id,updated_at,title,date,body'
      });
    }

    window.IndexedDb = this;
  }

  static get dexie() {
    return db;
  }
}


