<page-share>
  <div class="container">
    <div class="row">
      <div class="col m9 s12">
        <h4>{ this.nippo.sharedTitle }</h4>
      </div>
      <div class="col m3 s12">
        <h5>{ `${this.nippo.date.substring(0, 4)}/${this.nippo.date.substring(4, 6)}/${this.nippo.date.substring(6, 8)}` }</h5>
      </div>
    </div>

    <div class="row">
      <div id="md2html" class="col s12" />
    </div>
  </div>
  <div id="password-modal" class="modal bottom-sheet">
    <div class="modal-content">
      <div class="row">
        <div class="col s12">
          <h4>この日暮里は暗号化されています</h4>
        </div>
      </div>
      <div class="row">
        <div class="col s12 input-field">
          <input id="shared-password" type="password" class="active nippo-input" value="">
          <label for="shared-password">復号パスワードを入力してください</label>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="modal-action modal-close waves-effect waves-green btn-flat">完了</button>
    </div>
  </div>

  <style>

  </style>

  <script>
    import aesjs from 'aes-js';
    import sha256 from 'js-sha256';
    import {EventWorker} from "../../js/eventWorker";

    const self = this;

    this.nippo = {
      sharedTitle: '',
      sharedBody: '',
      date: '19700101',
      isEncrypted: false,
    };

    this.sharedTitleOrig = '';
    this.sharedBodyOrig = '';

    getSharedNippoDone(nippo) {
      self.nippo = nippo;
      self.update();

      if (!nippo.isEncrypted) {
        EventWorker.event.trigger('md2html:raise', self.nippo.sharedBody);
      } else {
        self.sharedTitleOrig = decodeURIComponent(self.nippo.sharedTitle);
        self.sharedBodyOrig = decodeURIComponent(self.nippo.sharedBody);

        $('#password-modal').modal('open');
      }

      EventWorker.event.trigger('showToast', '共有された日暮里を取得しました');
    }

    getSharedNippoError() {
      EventWorker.event.trigger('showToast', '共有された日暮里の取得に失敗しました');
    }

    aes256ctrDecrypt(target, password) {
      const key = sha256.array(password);
      const encryptedBytes = aesjs.utils.hex.toBytes(target);
      const aesCtr = new aesjs.ModeOfOperation.ctr(key, new aesjs.Counter(password.length));
      const decryptedBytes = aesCtr.decrypt(encryptedBytes);
      return aesjs.utils.utf8.fromBytes(decryptedBytes);
    }

    onInput(e) {
      if (e.originalEvent.keyCode === 13) {
        $('#password-modal').modal('close');
        return;
      }

      const password = $('#shared-password').val();
      self.nippo.sharedTitle = decodeURIComponent(self.aes256ctrDecrypt(self.sharedTitleOrig, password));
      self.nippo.sharedBody = decodeURIComponent(self.aes256ctrDecrypt(self.sharedBodyOrig, password));
      self.update();

      EventWorker.event.trigger('md2html:raise', self.nippo.sharedBody);
    }

    md2htmlDone(html) {
      riot.mount('div#md2html', 'common-raw', {content: html});
    }

    this.on('mount', () => {
      $('.modal').modal();
      $('.nippo-input').on('keyup', self.onInput);

      EventWorker.event.on('getSharedNippo:done', self.getSharedNippoDone);
      EventWorker.event.on('getSharedNippo:error', self.getSharedNippoError);
      EventWorker.event.on('md2html:done', self.md2htmlDone);

      EventWorker.event.trigger('getSharedNippo:raise', self.opts.username, self.opts.hash);
    });

    this.on('before-unmount', () => {
      $('.nippo-input').off('keyup', self.onInput);

      EventWorker.event.off('getSharedNippo:done', self.getSharedNippoDone);
      EventWorker.event.off('getSharedNippo:error', self.getSharedNippoError);
      EventWorker.event.off('md2html:done', self.md2htmlDone);
    });
  </script>
</page-share>
