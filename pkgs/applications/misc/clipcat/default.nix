{ lib
, fetchFromGitHub
, rustPlatform
, protobuf
, xvfb-run
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "clipcat";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "xrelkd";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2Sh8VakHeAotdw1kkpRgNtLj1gnH1Ei7OC9INF/lkZo=";
  };

  cargoHash = "sha256-cgyvIu56Ab3h6tgyQxtGsR0UPxgL65vb7fUAc0lMj5Q=";

  nativeBuildInputs = [
    protobuf
    installShellFiles
  ];

  nativeCheckInputs = [
    xvfb-run
  ];

  useNextest = true;

  # cargo-nextest help us retry the failed test cases
  NEXTEST_RETRIES = 5;

  # Some test cases interact with X11, we use xvfb-run here
  checkPhase = ''
    xvfb-run --auto-servernum cargo nextest run --release --workspace --no-fail-fast --no-capture
  '';

  postInstall = ''
    for cmd in clipcatd clipcatctl clipcat-menu clipcat-notify; do
      installShellCompletion --cmd $cmd \
        --bash <($out/bin/$cmd completions bash) \
        --fish <($out/bin/$cmd completions fish) \
        --zsh  <($out/bin/$cmd completions zsh)
    done
  '';

  meta = with lib; {
    description = "Clipboard Manager written in Rust Programming Language";
    homepage = "https://github.com/xrelkd/clipcat";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ xrelkd ];
    mainProgram = "clipcatd";
  };
}
