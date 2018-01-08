<common-edit>
  <div class="row">
    <form class="col s12">
      <div id="nippo-meta" class="row" style="margin-bottom:0">
        <div class="col s12">
          <div class="row">
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
        </div>

      </div>
      <div id="markdown-content" class="row { this.zenMode ? 'zen' : '' }">
        <textarea id="simplemde"></textarea>
      </div>
    </form>

    <div id="save-button" class="fixed-action-btn vertical">
      <a class="btn-floating btn-large red">
        <i class="large material-icons">menu</i>
      </a>
      <ul>
        <li><button class="btn-floating waves-effect waves-light red darken-2 tooltipped" data-position="left" data-delay="50" data-tooltip="保存" onclick="{ this.nippoSaveExec }"><i class="material-icons">save</i></button></li>
        <li><button class="btn-floating waves-effect waves-light red darken-2 modal-trigger tooltipped" data-position="left" data-delay="50" data-tooltip="共有" data-target="share-option-modal"><i class="material-icons">share</i></button></li>
        <li><button class="btn-floating waves-effect waves-light red darken-2 tooltipped" data-position="left" data-delay="50" data-tooltip="Zenモード" onclick="{ this.toggleZenMode }"><i class="material-icons">{ this.zenMode ? 'layers_clear' : 'layers' }</i></button></li>
      </ul>
    </div>
  </div>
  <div id="share-option-modal" class="modal bottom-sheet">
    <div class="modal-content">
      <div class="row">
        <div class="col s12">
          <div onclick="{ this.onClickShareCheckbox }">
            <input id="is-shared" type="checkbox" class="filled-in" checked="{ this.isShared }"/>
            <label for="is-shared">この日暮里を共有する （保存時に反映されます）</label>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="input-field col s12">
          <input disabled="{ disabled: !this.isShared }" id="shared-password" type="password" class="active nippo-input" value="{ this.sharedPassword }">
          <label for="shared-password">共有用エンドツーエンド暗号化パスワード</label>
        </div>
      </div>
      <div class="row">
        <div class="input-field col l10 m9 s12">
          <input disabled="disabled" id="shared-permalink" type="text" class="validate active" value="{ this.sharedPermalink }">
          <label for="shared-permalink">共有用パーマリンク</label>
        </div>
        <div class="col l2 m3 s12">
          <button id="copy-permalink" class="btn waves-effect waves-light right { disabled: !this.isShared }" onclick="{ this.onClickCopyPermalinkButton }">コピー
            <i class="material-icons left">content_copy</i>
          </button>
        </div>
      </div>
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

    #nippo-meta .col {
      padding: 0;
    }

    .modal-content input,
    #nippo-meta input {
      margin-bottom: 0 !important;
    }

    .modal-content #copy-permalink {
      top: 20px;
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

    #markdown-content.zen {
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      bottom: 0;
      margin: 0;
      z-index: 99999;
    }

    #save-button {
      position: fixed;
      bottom: 1em;
      right: 1em;
      z-index: 99999;
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

    this.touchY = 0;

    this.id = null;
    this.title = '';
    this.date = `${today.getFullYear()}/${today.getMonth() + 1}/${today.getDate()}`;
    this.body = '';
    this.isShared = false;
    this.sharedPassword = '';
    this.sharedHash = ''
    this.sharedPermalink = '';

    this.simplemde = null;
    this.zenMode = false;

    // https://qiita.com/nandai@github/items/d821df077fcf2e8854dd
    onTouchStart(e) {
      self.touchY = e.touches[0].screenY;
    }

    // https://qiita.com/nandai@github/items/d821df077fcf2e8854dd
    onTouchMove(e) {
      let el = e.target;
      const moveY = e.touches[0].screenY;
      let noScroll = true;

      while (el !== null)
      {
        if (el.offsetHeight < el.scrollHeight)
        {
          if (self.touchY < moveY && el.scrollTop === 0) {
            break;
          }

          if (self.touchY > moveY && el.scrollTop === el.scrollHeight - el.offsetHeight) {
            break;
          }

          noScroll = false;
          break;
        }
        el = el.parentElement;
      }

      if (noScroll) {
        e.preventDefault();
      }

      self.touchY = moveY;
    }

    onInput(e) {
      if (e.type && e.type.toLowerCase() === 'keyup') {
        self.title = $('#title').val();
        self.date = $('#date').val();
        self.sharedPassword = $('#shared-password').val();
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

      if (localStorage.e2eEncPassword && localStorage.e2eEncPassword !== '' && self.sharedPassword === '') {
        error = true;
        EventWorker.event.trigger('showToast', '共有用エンドツーエンド暗号化パスワードを入力してください');
      }

      if (error) {
        return;
      }

      EventWorker.event.trigger('nippoSave:raise', {
        id: self.id,
        title: self.title,
        date: self.date.split('/').join(''),
        body: self.body,
        isShared: self.isShared,
        sharedPassword: self.sharedPassword,
        sharedHash: self.sharedHash,
      });
    }

    nippoSaveDone(id, dbObj) {
      self.id = id;
      console.log('onNippoSaveDone:', dbObj);
      EventWorker.event.trigger('showToast', 'ローカル データベースに保存しました');

      if(localStorage.autoSyncRemoteDatabase) {
        EventWorker.event.trigger('updateRemoteNippo:raise', {
          id: self.id,
          title: self.title,
          date: self.date.split('/').join(''),
          body: self.body,
          isShared: self.isShared,
          sharedPassword: self.sharedPassword,
        }, localStorage.e2eEncPassword);
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
      self.isShared = nippo.isShared || false;
      self.sharedPassword = nippo.sharedPassword || '';
      self.sharedHash = nippo.sharedHash || '';
      if (self.sharedHash && self.sharedHash !== '' && localStorage.username) {
        self.sharedPermalink = `${location.origin}${location.pathname}#/nippo/share/${localStorage.username}/${self.sharedHash}`;
      }
      self.simplemde.value(self.body);
//      EventWorker.event.trigger('md2html:raise', self.body);
      self.update();

      if (Materialize && Materialize.updateTextFields) {
        Materialize.updateTextFields();
      }
      $('#title').trigger('keydown');
      $('#date').trigger('keydown');
      if (Materialize && Materialize.updateTextFields) {
        Materialize.updateTextFields();
      }
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

    exportRemoteDBDone(remoteNippoObj) {
      console.log(remoteNippoObj);
      if (remoteNippoObj && remoteNippoObj.sharedHash && remoteNippoObj.sharedHash !== '') {
        self.sharedHash = remoteNippoObj.sharedHash;
        if (localStorage.username) {
          self.sharedPermalink = `${location.origin}${location.pathname}#/nippo/share/${localStorage.username}/${self.sharedHash}`;
        }

        self.update();
        if (Materialize && Materialize.updateTextFields) {
          Materialize.updateTextFields();
        }
        EventWorker.event.trigger('nippoUpdate:raise', {
          id: remoteNippoObj.nippoId,
          sharedHash: remoteNippoObj.sharedHash,
        });
      }
      EventWorker.event.trigger('showToast', 'リモート データベースにエクスポートしました');
    }

    exportRemoteDBError() {
      EventWorker.event.trigger('showToast', 'リモート データベースへのエクスポートに失敗しました');
    }

    toggleZenMode() {
      self.zenMode = !self.zenMode;
      self.update();
    }

    onClickShareCheckbox() {
      self.isShared = document.querySelector('#is-shared').checked;
    }

    onClickCopyPermalinkButton() {
      const permalink = self.sharedPermalink;
      if (!permalink || permalink === '') {
        EventWorker.event.trigger('showToast', '共有用パーマリンクは保存後に生成されます');
        return;
      }

      if (!document.execCommand) {
        EventWorker.event.trigger('showToast', 'ブラウザにHTML5 Editing APIが実装されていません');
        return;
      }

      const p = document.createElement('p');
      document.body.appendChild(p);
      p.innerHTML = permalink;

      let result;
      try {
        const range = document.createRange();
        range.selectNode(p);
        window.getSelection().removeAllRanges();
        window.getSelection().addRange(range);
        result = document.execCommand('copy');
        window.getSelection().removeAllRanges();
      } finally {
        document.body.removeChild(p);
      }

      if (result) {
        EventWorker.event.trigger('showToast', '共有用パーマリンクをコピーしました');
      } else {
        EventWorker.event.trigger('showToast', '共有用パーマリンクのコピーに失敗しました');
      }
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
      $(window).off('keydown', self.hookCtrlS);

      if (window.navigator.standalone) {
        $('body').off('touchstart', self.onTouchStart);
        $('body').off('touchmove', self.onTouchMove);
      }

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

      $('.modal').modal();
      $('.tooltipped').tooltip();

      EventWorker.event.on('md2html:done', self.md2htmlDone);
      EventWorker.event.on('nippoSave:done', self.nippoSaveDone);
      EventWorker.event.on('nippoSave:error', self.nippoSaveError);
      EventWorker.event.on('nippoGet:done', self.getNippoDone);
      EventWorker.event.on('nippoGet:error', self.getNippoError);
      EventWorker.event.on('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.on('syncExportDB:error', self.exportRemoteDBError);
      $('.nippo-input').on('keyup', self.onInput);
      $(window).on('keydown', self.hookCtrlS);

      if (window.navigator.standalone) {
        $('body').on('touchstart', self.onTouchStart);
        $('body').on('touchmove', self.onTouchMove);
      }

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
