<common-header>
  <header>
    <div class="navbar-fixed">
      <nav>
        <div class="nav-wrapper teal white-text">

          <ul class="left">
            <li>
              <a id="header-antergos-jp-logo-link" href="#/" class="brand-logo">
                <div>Nippo:Re</div>
              </a>
            </li>
          </ul>
          <ul class="right hide-on-med-and-down">
            <li><a href="#/nippo/create"><i class="material-icons left">mode_edit</i>書く</a></li>
            <li><a href="#/nippo/list"><i class="material-icons left">list</i>一覧</a></li>
            <li><a href="#/about"><i class="material-icons left">info</i>Nippo:Reについて</a></li>
          </ul>

          <a href="javascript:void(0);" class="button-collapse" data-activates="mobile-menu"><i class="material-icons">menu</i></a>
        </div>
      </nav>
    </div>
    <div>
      <ul class="side-nav" id="mobile-menu">
        <li><a href="#/nippo/create"><i class="material-icons left">mode_edit</i>書く</a></li>
        <li><a href="#/nippo/list"><i class="material-icons left">list</i>一覧</a></li>
        <li><a href="#/about"><i class="material-icons left">info</i>Nippo:Reについて</a></li>
      </ul>
    </div>
  </header>

  <style>
    .brand-logo > * {
      padding: 0 0.5rem;
    }
  </style>

  <script>
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

      EventWorker.event.on('hashChanged', (hash) => {
        console.log(hash);
      });
    });

  </script>
</common-header>
