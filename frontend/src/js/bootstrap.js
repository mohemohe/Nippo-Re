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
import '../tag/page/settings.tag';
import '../tag/page/login.tag';
import '../tag/page/signup.tag';

import { EventWorker } from './eventWorker';
import { IndexedDb } from './indexedDb';

window.Materialize = Materialize;

EventWorker.initialize();
IndexedDb.initialize();

document.title = 'Nippo:Re';

//riot謹製ルーターではなく https://github.com/gabrielmoreira/riot-router を使用
router.routes([
  new Router.DefaultRoute({tag: 'page-list'}),
  new Router.NotFoundRoute({tag: 'common-notfound'}),
  new Router.Route({path: '/about', tag: 'page-about'}),
  new Router.Route({path: '/settings', tag: 'page-settings'}),
  new Router.Route({path: '/nippo/list', tag: 'page-list'}),
  new Router.Route({path: '/nippo/create', tag: 'page-create'}),
  new Router.Route({path: '/nippo/edit/:nippoId', tag: 'page-edit'}),
  new Router.Route({path: '/login', tag: 'page-login'}),
  new Router.Route({path: '/signup', tag: 'page-signup'}),
]);

router.on('route:updated', () => {
  EventWorker.event.trigger('hashChanged', location.hash);
  window.scrollTo(0, 0);
});

riot.mount('*');
router.start();
