import riot from 'riot';
import * as Worker from './worker/index';
export class EventWorker {
  static initialize() {
    window.__store = {};
    window.__event = riot.observable();
    window.EventWorker = this;

    Object.keys(Worker).forEach((worker) => {
      EventWorker.register(`${worker}:raise`, worker)
    })
  }

  static register(event, worker) {
    if(typeof worker === typeof '') {
      window.__event.on(event, Worker[worker]);
      console.info('register worker (string):', event, Worker[worker]);
    } else {
      window.__event.on(event, worker);
      console.info('register worker (function):', event, worker);
    }
  }

  static get event() {
    return window.__event;
  }

  static get store() {
    return window.__store;
  }
}
