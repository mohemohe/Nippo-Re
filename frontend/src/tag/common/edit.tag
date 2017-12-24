<common-edit>
  <div class="row">
    <form class="col s12">
      <div class="row" style="margin-bottom:0">
        <div class="input-field col m9 s12">
          <i class="material-icons prefix">title</i>
          <input id="title" type="text" class="validate active nippo-input" value="{ this.title }">
          <label for="title">タイトル</label>
        </div>
        <div class="input-field col m3 s12">
          <i class="material-icons prefix">today</i>
          <input value="{ this.date }" id="date" type="text" class="datepicker active nippo-input">
          <label for="date"></label>
        </div>
      </div>
      <div id="markdown-content" class="row">
        <textarea id="simplemde"></textarea>
      </div>
    </form>

    <div id="save-button">
      <a class="btn-floating btn-large waves-effect waves-light red"><i class="material-icons">save</i></a>
    </div>
  </div>

  <style>
    :scope form {
      display: flex;
      flex-direction: column;
      height: 100vh;
      padding-top: calc(64px + 0.5rem) !important;
      position: absolute;
      top: 0;
    }

    :scope form .row {
      width: 100%;
    }

    #markdown-content {
      flex: 1;
      width: 100%;
      position: relative;
      display: flex;
      flex-direction: column;
      font-size: 16px;
    }

    #simplemde {
      height: 100%;
    }

    #markdown-content .CodeMirror {
      min-height: 0 !important;
      flex: 1;
    }

    #markdown-content .editor-toolbar.fullscreen,
    #markdown-content .CodeMirror-fullscreen,
    #markdown-content .editor-preview-side {
      position: absolute !important;
    }

    #markdown-content .fa-arrows-alt {
      display: none;
    }

    #markdown-content .editor-toolbar {
      border-top: 1px solid #ddd !important;
      border-left: 1px solid #ddd !important;
      border-right: 1px solid #ddd !important;
      border-top-left-radius: 4px !important;
      border-top-right-radius: 4px !important;
    }

    #markdown-content .editor-preview-side {
      border-left: 0 !important;
    }

    #save-button {
      position: fixed;
      bottom: 1em;
      right: 1em;
      z-index: 9999;
    }

    input, textarea {
      font-size: 16px !important;
    }

    @media (max-width: 767px) {
      #markdown-content .CodeMirror {
        width: 100% !important;
      }

      #markdown-content .editor-preview-side {
        display: none;
      }
    }
  </style>

  <script>
    import {EventWorker} from "../../js/eventWorker";

    const self = this;
    const today = new Date();

    this.id = null;
    this.title = '';
    this.date = `${today.getFullYear()}/${today.getMonth() + 1}/${today.getDate()}`;
    this.body = '';

    this.simplemde = null;

    onInput(e) {
      if (e.type && e.type.toLowerCase() === 'keyup') {
        self.title = $('#title').val();
        self.date = $('#date').val();
      } else {
        self.body = self.simplemde.value();
      }

//      EventWorker.event.trigger('md2html:raise', self.body);
    }

    md2htmlDone(html) {
      riot.mount('div#md2html', 'common-raw', {content: html});
    }

    nippoSaveExec() {
      let error = false;
      if(self.title === '') {
        error = true;
        EventWorker.event.trigger('showToast', 'タイトルを入力してください');
      }

      if(self.date === '') {
        error = true;
        EventWorker.event.trigger('showToast', '日付を入力してください');
      }

      if(self.body === '') {
        error = true;
        EventWorker.event.trigger('showToast', '本文を入力してください');
      }

      if (error) {
        return;
      }

      EventWorker.event.trigger('nippoSave:raise', {
        id: self.id,
        title: self.title,
        date: self.date.split('/').join(''),
        body: self.body,
      });
    }

    nippoSaveDone(id) {
      self.id = id;
      EventWorker.event.trigger('showToast', 'ローカル データベースに保存しました');

      if(localStorage.autoSyncRemoteDatabase) {
        EventWorker.event.trigger('syncExportDB:raise', localStorage.e2eEncPassword);
      }
    }

    nippoSaveError() {
      EventWorker.event.trigger('showToast', 'ローカル データベースへの保存に失敗しました');
    }

    getNippoDone(nippo) {
      self.id = nippo.id;
      self.title = nippo.title;
      self.date = `${nippo.date.substring(0, 4)}/${nippo.date.substring(4, 6)}/${nippo.date.substring(6, 8)}`;
      self.body = nippo.body;
      self.simplemde.value(self.body);
//      EventWorker.event.trigger('md2html:raise', self.body);
      self.update();

      Materialize.updateTextFields();
      $('#title').trigger('keydown');
      $('#date').trigger('keydown');
      Materialize.updateTextFields();
    }

    getNippoError() {
      EventWorker.event.trigger('showToast', 'ローカル データベースの取得に失敗しました');
    }

    hookCtrlS(event) {
      if((event.ctrlKey || event.metaKey) && event.which == 83) {
        self.nippoSaveExec();

        event.preventDefault();
        return false;
      }
    }

    exportRemoteDBDone() {
      EventWorker.event.trigger('showToast', 'リモート データベースにエクスポートしました');
    }

    exportRemoteDBError() {
      EventWorker.event.trigger('showToast', 'リモート データベースへのエクスポートに失敗しました');
    }

    dispose() {
      EventWorker.event.off('md2html:done', self.md2htmlDone);
      EventWorker.event.off('nippoSave:done', self.nippoSaveDone);
      EventWorker.event.off('nippoSave:error', self.nippoSaveError);
      EventWorker.event.off('nippoGet:done', self.getNippoDone);
      EventWorker.event.off('nippoGet:error', self.getNippoError);
      EventWorker.event.off('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.off('syncExportDB:error', self.exportRemoteDBError);
      $('.nippo-input').off('keyup', self.onInput);
      $('#save-button').off('click', self.nippoSaveExec);
      $(window).off('keydown', self.hookCtrlS);

      document.querySelector('html').classList.remove('edit');
    }

    this.on('mount', () => {
      document.querySelector('html').classList.add('edit');

      self.simplemde = new window.SimpleMDE({
        autofocus: true,
        autosave: {
          enabled: false,
        },
        element: document.querySelector('#simplemde'),
        initialValue: "",
        placeholder: "MarkdownまたはHTMLで入力できます",
        renderingConfig: {
          codeSyntaxHighlighting: true,
        },
        spellChecker: false,
        status: false,
        tabSize: 4,
//        toolbar: true,
        toolbarTips: false,
      });
      try {
        self.simplemde.toggleSideBySide();
      } catch (e) {
        console.error('error on auto split view', e);
      }
      self.simplemde.codemirror.on('change', self.onInput);

      $('.datepicker').pickadate({
        monthsFull:  ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
        monthsShort: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
        weekdaysFull: ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
        weekdaysShort:  ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
        weekdaysLetter: ["日", "月", "火", "水", "木", "金", "土"],
        labelMonthNext: "翌月",
        labelMonthPrev: "前月",
        labelMonthSelect: "月を選択",
        labelYearSelect: "年を選択",
        today: "今日",
        clear: "クリア",
        close: "閉じる",
        format: "yyyy/mm/dd",
        onClose: function( arg ){
          self.date = $('#date').val();
        }
      });

      EventWorker.event.on('md2html:done', self.md2htmlDone);
      EventWorker.event.on('nippoSave:done', self.nippoSaveDone);
      EventWorker.event.on('nippoSave:error', self.nippoSaveError);
      EventWorker.event.on('nippoGet:done', self.getNippoDone);
      EventWorker.event.on('nippoGet:error', self.getNippoError);
      EventWorker.event.on('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.on('syncExportDB:error', self.exportRemoteDBError);
      $('.nippo-input').on('keyup', self.onInput);
      $('#save-button').on('click', self.nippoSaveExec);
      $(window).on('keydown', self.hookCtrlS);

      const id = parseInt(self.parent.opts.nippoId, 10);
      if(!isNaN(id)) {
        EventWorker.event.trigger('nippoGet:raise', id);
      }
    });

    this.on('before-unmount', () => {
      self.dispose();
    });
  </script>
</common-edit>
