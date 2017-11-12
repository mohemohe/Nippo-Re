import $ from 'jquery';
import Materialize from 'materialize-css';
import riot from 'riot';
import Router from 'riot-router';

import '../tag/app.tag';
import '../tag/common/notfound.tag';
import '../tag/common/header.tag';
import '../tag/common/raw.tag';
import '../tag/common/edit.tag';
import '../tag/page/index.tag';
import '../tag/page/create.tag';
import '../tag/page/edit.tag';
import '../tag/page/list.tag';
import '../tag/page/about.tag';

import { IndexedDb } from './indexedDb';

import { EventWorker } from './eventWorker';
import * as Worker from './worker';

document.title = 'Nippo:Re';

//riot謹製ルーターではなく https://github.com/gabrielmoreira/riot-router を使用
router.routes([
  new Router.DefaultRoute({tag: 'page-list'}),
  new Router.NotFoundRoute({tag: 'common-notfound'}),
  new Router.Route({path: '/about', tag: 'page-about'}),
  new Router.Route({path: '/nippo/list', tag: 'page-list'}),
  new Router.Route({path: '/nippo/create', tag: 'page-create'}),
  new Router.Route({path: '/nippo/edit/:nippoId', tag: 'page-edit'}),
]);

EventWorker.initialize();

router.on('route:updated', () => {
  EventWorker.event.trigger('hashChanged', location.hash);
  window.scrollTo(0, 0);
});

EventWorker.register('md2html:exec', Worker.md2html);
EventWorker.register('saveNippo:exec', Worker.nippoSave);
EventWorker.register('listNippo:exec', Worker.nippoList);
EventWorker.register('getNippo:exec', Worker.nippoGet);

IndexedDb.initialize();

riot.mount('*');
router.start();
