import { EventWorker } from '../eventWorker';

const marked = require('marked');

let _renderer;

export function md2html(text) {
  if(!_renderer) {
    _renderer = new marked.Renderer();
  }

  marked.setOptions({
    renderer: _renderer,
    gfm: true,
    tables: true,
    breaks: false,
    pedantic: false,
    sanitize: false,
    smartLists: true,
    smartypants: false
  });

  EventWorker.event.trigger('md2html:done', marked(text));
}
