<common-header>
  <header>
    <div class="navbar-fixed">
      <nav>
        <div class="nav-wrapper teal white-text">

          <ul class="left">
            <li>
              <a id="header-logo-link" href="#/" class="brand-logo">
                <img src="/images/nippore-logo-white.png" alt="Nippo:Re">
              </a>
            </li>
          </ul>
          <ul class="right hide-on-med-and-down">
            <li><a href="#/nippo/create"><i class="material-icons left">mode_edit</i>書く</a></li>
            <li><a href="#/nippo/list"><i class="material-icons left">list</i>一覧</a></li>
            <li><a href="#/settings"><i class="material-icons left">settings</i>設定</a></li>
            <li><a href="#/about"><i class="material-icons left">info</i>Nippo:Reについて</a></li>
            <li show="{ localStorage.username }"><a class="dropdown-button" href="javascript:void(0)" data-activates="account-dropdown"><i class="material-icons left">person</i>ID: { localStorage.username }<i class="material-icons right">arrow_drop_down</i></a></li>
            <li show="{ !localStorage.username }"><a href="#/login"><i class="material-icons left">person</i>ログイン / 新規登録</a></li>
          </ul>
          <ul id="account-dropdown" class="dropdown-content">
            <li><a href="javascript:void(0)" onclick="{ logout }">ログアウト</a></li>
          </ul>

          <a href="javascript:void(0);" class="button-collapse" data-activates="mobile-menu"><i class="material-icons">menu</i></a>
        </div>
      </nav>
    </div>
    <div>
      <ul class="side-nav" id="mobile-menu">
        <li><a href="#/nippo/create"><i class="material-icons left">mode_edit</i>書く</a></li>
        <li><a href="#/nippo/list"><i class="material-icons left">list</i>一覧</a></li>
        <li><a href="#/settings"><i class="material-icons left">settings</i>設定</a></li>
        <li><a href="#/about"><i class="material-icons left">info</i>Nippo:Reについて</a></li>

        <li class="divider"></li>

        <li show="{ localStorage.username }"><a href="javascript:void(0)"><i class="material-icons left">person</i>ID: { localStorage.username }</a></li>
        <li show="{ localStorage.username }"><a href="javascript:void(0)" onclick="{ logout }">ログアウト</a></li>
        <li show="{ !localStorage.username }"><a href="#/login"><i class="material-icons left">person</i>ログイン / 新規登録</a></li>

      </ul>
    </div>
  </header>

  <style>
    header,
    header nav {
      position: fixed;
      z-index: 99999;
    }

    nav {
      height: 64px !important;
      min-height: 64px !important;
      max-height: 64px !important;
    }

    .brand-logo {
      max-height: 64px;
    }

    @media (max-width: 600px) {
      nav {
        height: 56px !important;
        min-height: 56px !important;
        max-height: 56px !important;
      }

      .brand-logo {
        max-height: 56px;
      }
    }


    .brand-logo > * {
      padding: 0.666rem;
      max-height: inherit;
    }

    #account-dropdown {
      top: 64px !important;
    }
  </style>

  <script>
    import {EventWorker} from "../../js/eventWorker";

    const self = this;

    onGetUserName() {
      self.update();
    }

    logout() {
      EventWorker.event.trigger('apiLogout:raise');
    }

    onLogout() {
      self.update();
    }

    this.on('mount', () => {
      $(".button-collapse").sideNav({
        closeOnClick: true,
      });
      $(".mobile-dropdown-button").dropdown({
        belowOrigin: true,
        stopPropagation: true,
      });
      $(".dropdown-button").dropdown({
        belowOrigin: true,
      });

      EventWorker.event.on('apiGetUserName:done', self.onGetUserName);
      EventWorker.event.on('apiLogout:done', self.onLogout);
    });

  </script>
</common-header>
