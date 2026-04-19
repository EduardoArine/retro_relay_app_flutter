import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multicast_dns/multicast_dns.dart';

final mdnsServiceProvider = Provider<MdnsService>((_) => MdnsService());

class MdnsService {
  // Tenta descobrir o ESP32 na rede local via mDNS.
  // Retorna o IP como string, ou null se não encontrado dentro do timeout.
  Future<String?> discover({
    String serviceType = '_http._tcp',
    String hostname = 'retro-relay.local',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final client = MDnsClient();
    try {
      await client.start();

      // Primeiro tenta resolver o hostname diretamente
      final ipByHost = await _resolveByHost(client, hostname, timeout);
      if (ipByHost != null) return ipByHost;

      // Fallback: procura serviços _http._tcp e filtra pelo nome
      return await _resolveByService(client, serviceType, timeout);
    } catch (_) {
      return null;
    } finally {
      client.stop();
    }
  }

  Future<String?> _resolveByHost(
      MDnsClient client, String hostname, Duration timeout) async {
    try {
      await for (final record
          in client.lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(hostname),
      ).timeout(timeout, onTimeout: (_) {})) {
        return record.address.address;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _resolveByService(
      MDnsClient client, String serviceType, Duration timeout) async {
    try {
      await for (final ptr
          in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(serviceType),
      ).timeout(timeout, onTimeout: (_) {})) {
        await for (final srv
            in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
        ).timeout(const Duration(seconds: 2), onTimeout: (_) {})) {
          await for (final ip
              in client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target),
          ).timeout(const Duration(seconds: 2), onTimeout: (_) {})) {
            return ip.address.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
