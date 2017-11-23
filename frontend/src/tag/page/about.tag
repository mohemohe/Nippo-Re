<page-about>
  <div class="container">
    <div class="row">
      <div class="col s12">
        <div id="logo-container">
          <img src="./images/nippore-logo-dark.png" alt="Nippo:Re">
        </div>
      </div>
      <div class="col s12">
        <div id="copyright" class="right">© 2017{ new Date().getFullYear() === 2017 ? '' : ' - ' + new Date().getFullYear() } mohemohe Some Rights Reserved.</div>
      </div>
    </div>

    <div class="row">
      <div class="col l6 s12">
        <h3>Nippo:Reについて</h3>
        <p>
          Nippo:Reは日報を雑に書き溜めるために作成されています。<br>
          別に日報じゃなくてもメモとかポエムとかを書いてもいいです。
        </p>
        <p>
          エントリーはブラウザーのIndexedDBに保存されます。<br>
          ブラウザーやPCを変えると別の環境・ユーザーとして扱われます。
        </p>
        <p>
          アプリが動作するためのデータを読み込む以外はサーバーと通信していません。<br>
          サーバー側で日報のバックアップは取っていないので、うっかりデータを消さないように注意してください。
        </p>
      </div>

      <div class="col l6 s12">
        <h3>日暮里について</h3>
        <p>
          通過したことはありますが、降りたことはないです。
        </p>
      </div>
    </div>
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
