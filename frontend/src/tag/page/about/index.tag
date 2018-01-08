<page-about>
  <div class="container">
    <div class="row">
      <div class="col s12">
        <div id="logo-container">
          <img src="./images/nippore-logo-dark.png" alt="Nippo:Re">
        </div>
      </div>
      <div class="col s12">
        <div id="copyright" class="right">© 2017{ new Date().getFullYear() === 2017 ? '' : ` - ${new Date().getFullYear()}` } mohemohe some rights reserved.</div>
      </div>
    </div>

    <page-built-with/>

    <div class="row">
      <div class="col l6 s12">
        <h3>Nippo:Reについて</h3>
        <p>
          Nippo:Reは日報を雑に書き溜めるために作成されていましたが、もう便利なメモサイトってことでいいです。
        </p>
        <p>
          エントリーはブラウザーのIndexedDBに保存されます。<br>
          ブラウザーやPCを変えると別の環境・ユーザーとして扱われます。
        </p>
        <p>
          初期設定では、アプリが動作するためのデータを読み込む以外はサーバーと通信していません。<br>
          あくまでもデータをローカルで扱うことをコンセプトにしています。
        </p>

        <p>
          サーバーに日報のバックアップを保存したい場合は、アカウントを登録してデータのエクスポートを行ってください。<br>
          エンドツーエンド暗号化パスワードを設定すると、AES 256bitによる金融機関レベルの強力な暗号化をローカルで行います。
        </p>
      </div>

      <div class="col l6 s12">
        <h3>日暮里について</h3>
        <p>
          通過したことはありますが、降りたことはないです。
        </p>
      </div>
    </div>

    <common-terms-of-service/>
  </div>


  <style>
    #logo-container,
    #logo-container > img {
      max-width: 100%;
    }

    #copyright {
      margin-top: -1em;
      font-size: 1.66vw;
    }
  </style>
</page-about>
