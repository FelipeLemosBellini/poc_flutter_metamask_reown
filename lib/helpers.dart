import 'package:reown_appkit/modal/utils/public/appkit_modal_networks_utils.dart';

List<String> getChainMethods(String namespace) {
  switch (namespace) {
    case 'eip155':
      return [
        'personal_sign',
        'eth_sign',
        'eth_signTypedData',
        'eth_signTypedData_v4',
        'eth_signTransaction',
        'eth_sendTransaction',
      ];
    case 'solana':
      return [
        'solana_signMessage',
        'solana_signTransaction',
        'solana_signAndSendTransaction',
        'solana_signAllTransactions',
      ];
    default:
      return [];
  }
}

List<String> getChainEvents(String namespace) {
  switch (namespace) {
    case 'eip155':
      return NetworkUtils.defaultNetworkEvents['eip155']!.toList();
    case 'solana':
      return NetworkUtils.defaultNetworkEvents['solana']!.toList();
    default:
      return [];
  }
}
