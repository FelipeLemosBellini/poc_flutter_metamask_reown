import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:reown_appkit/appkit_modal.dart';
import 'package:reown_appkit/base/appkit_base_impl.dart';
import 'package:reown_appkit/modal/widgets/public/appkit_modal_connect_button.dart';
import 'package:reown_core/reown_core.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:web3dart/crypto.dart';

import 'deep_link_handler.dart';
import 'helpers.dart';

class Modal {
  Modal();

  // late ReownWalletKit _walletKit;
  late ReownAppKit _appKit;

  late ReownAppKitModal _reownAppKitModal;

  // ReownWalletKit get walletKit => _walletKit;

  ReownAppKit get appKit => _appKit;

  String id = '';//add project id

  void createInstance(BuildContext context) async {
    _appKit = ReownAppKit(
      core: ReownCore(projectId: id, logLevel: LogLevel.all),
      metadata: _pairingMetadata(),
    );

    _reownAppKitModal = ReownAppKitModal(
      context: context,
      projectId: id,
      siweConfig: _siweConfig(true),
      appKit: appKit,
      logLevel: LogLevel.all,
      enableAnalytics: true,
      optionalNamespaces: _updatedNamespaces(),
      featuresConfig: FeaturesConfig(
        email: false,
        showMainWallets: true, // OPTIONAL - true by default
      ),
      featuredWalletIds: {
        'a797aa35c0fadbfc1a53e7f675162ed5226968b44a19ee3d24385c64d1d3c393',
        // Phantom
        'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa',
        // Coinbase
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
        // Metamask
      },
    );

    initDeepLink();
    await _reownAppKitModal.init();

    if (_reownAppKitModal.isConnected) {
      print("to conectado");
    } else {
      _reownAppKitModal.openModalView();
    }
  }

  void connect(BuildContext context) async {
    ReownAppKitModal appKitModal = ReownAppKitModal(context: context, appKit: appKit);

    AppKitModalConnectButton(appKit: appKitModal);
  }

  void initDeepLink() async {
    DeepLinkHandler.init(_reownAppKitModal);
    DeepLinkHandler.checkInitialLink();
  }

  String _universalLink() {
    Uri link = Uri.parse('https://appkit-lab.reown.com/flutter_appkit');
    return link.replace(path: link.path).toString();
  }

  Map<String, RequiredNamespace>? _updatedNamespaces() {
    Map<String, RequiredNamespace>? namespaces = {};

    final evmChains = ReownAppKitModalNetworks.getAllSupportedNetworks(namespace: 'eip155');
    if (evmChains.isNotEmpty) {
      namespaces['eip155'] = RequiredNamespace(
        chains: evmChains.map((c) => c.chainId).toList(),
        methods: getChainMethods('eip155'),
        events: getChainEvents('eip155'),
      );
    }
    final solanaChains = ReownAppKitModalNetworks.getAllSupportedNetworks(namespace: 'solana');
    if (solanaChains.isNotEmpty) {
      namespaces['solana'] = RequiredNamespace(
        chains: solanaChains.map((c) => c.chainId).toList(),
        methods: getChainMethods('solana'),
        events: getChainEvents('solana'),
      );
    }

    return namespaces;
  }

  PairingMetadata _pairingMetadata() {
    return PairingMetadata(
      name: 'Reown\'s AppKit',
      description: 'Reown\'s sample dApp with Flutter SDK',
      url: _universalLink(),
      icons: [
        'https://raw.githubusercontent.com/reown-com/reown_flutter/refs/heads/develop/assets/appkit-icon.png',
      ],
      redirect: Redirect(native: 'poc_metamask://', linkMode: true, universal: _universalLink()),
    );
  }

  SIWEConfig _siweConfig(bool enabled) => SIWEConfig(
    getNonce: () async {
      // this has to be called at the very moment of creating the pairing uri
      return SIWEUtils.generateNonce();
    },
    getMessageParams: () async {
      // Provide everything that is needed to construct the SIWE message
      debugPrint('[SIWEConfig] getMessageParams()');
      final url = _reownAppKitModal.appKit!.metadata.url;
      final uri = Uri.parse(url);
      return SIWEMessageArgs(
        domain: uri.authority,
        uri: 'https://${uri.authority}/login',
        statement: 'Welcome to AppKit $packageVersion for Flutter.',
        methods: MethodsConstants.allMethods,
      );
    },
    createMessage: (SIWECreateMessageArgs args) {
      // Create SIWE message to be signed.
      // You can use our provided formatMessage() method of implement your own
      debugPrint('[SIWEConfig] createMessage()');
      return SIWEUtils.formatMessage(args);
    },
    verifyMessage: (SIWEVerifyMessageArgs args) async {
      // Implement your verifyMessage to authenticate the user after it.
      debugPrint('[SIWEConfig] verifyMessage()');
      final chainId = SIWEUtils.getChainIdFromMessage(args.message);
      final address = SIWEUtils.getAddressFromMessage(args.message);
      final cacaoSignature =
          args.cacao != null
              ? args.cacao!.s
              : CacaoSignature(t: CacaoSignature.EIP191, s: args.signature);
      return await SIWEUtils.verifySignature(address, args.message, cacaoSignature, chainId, id);
    },
    getSession: () async {
      // Return proper session from your Web Service
      final chainId = _reownAppKitModal.selectedChain!.chainId;
      final namespace = NamespaceUtils.getNamespaceFromChain(chainId);
      final address = _reownAppKitModal.session!.getAddress(namespace)!;
      return SIWESession(address: address, chains: [chainId]);
    },
    onSignIn: (SIWESession session) {
      // Called after SIWE message is signed and verified
      debugPrint('[SIWEConfig] onSignIn()');
    },
    signOut: () async {
      // Called when user taps on disconnect button
      return true;
    },
    onSignOut: () {
      // Called when disconnecting WalletConnect session was successfull
      debugPrint('[SIWEConfig] onSignOut()');
    },
    enabled: enabled,
    signOutOnDisconnect: true,
    signOutOnAccountChange: false,
    signOutOnNetworkChange: false,
    // nonceRefetchIntervalMs: 300000,
    // sessionRefetchIntervalMs: 300000,
  );
}
