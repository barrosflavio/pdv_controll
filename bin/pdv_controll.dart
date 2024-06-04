import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:wake_on_lan/wake_on_lan.dart';

void main() async {

  Pdvs pdvslj10 = Pdvs(
      loja: 'Nome da Loja',
      pdv: ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
        '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21',
        '22', '23', '24', '25', '26', '00', '28'],
      mac: ['00:00:00:00:00:00',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo',
        'mac:do:dispositivo']
  );

  var ips = await NetworkInterface.list();
  var ip = ips.firstWhere(
          (element) => element.name == 'Ethernet',
      orElse: () => ips.first);
  String convertIp = ip.toString();
  String myDeviceIpv4 = (simpleSplit(fullString: convertIp, splitBy: "'")[3]);
  List<String> splitIpv4 = simpleSplit(fullString: myDeviceIpv4);
  print('IPV4: $myDeviceIpv4\n'
      'IPV4 em partes: $splitIpv4\n'
      'Loja: ${splitIpv4[2]}');

  print('------------------------------------------------------------------\n'
      '| Funções: |   L (Ligar)   |   R (Reiniciar)   |   D (Desligar)  |\n'
      '------------------------------------------------------------------');

  while (true) {
    print('\n'
        'Escolha uma função:');
    String? function = simpleInput();
    if (function == 'l') {
      for (String m in manList()) {
        int n = int.parse(m);
        if(m == pdvslj10.pdv[n]){
          print('O Mac do PDV $m é ${pdvslj10.mac[n]}');
          print('Ligando PDV: $m');
          String mac = pdvslj10.mac[n];
          String ipv4 = 'ipV4';
          MACAddress macAddress = MACAddress(mac);
          IPv4Address ipv4Address = IPv4Address(ipv4);
          WakeOnLAN wol = WakeOnLAN(ipv4Address, macAddress, port: 9);
          await wol.wake();
        } else {
          print('Algo deu errado ao comparar $m com ${pdvslj10.pdv[n]}');
        }
      }
    } else if (function == 'r') {
      for (String m in manList()) {
        print('Reiniciando PDV: $m');
        final client = SSHClient(
          await SSHSocket.connect('192.168.${splitIpv4[2]}.2$m', 22),
          username: 'usuario',
          onPasswordRequest: () => 'senha',
        );
        await client.run('shutdown -r +1');
        client.close();
      }
    } else if (function == 'd') {
      for (String m in manList()) {
        print('Desligando PDV: $m');
        final client = SSHClient(
          await SSHSocket.connect('192.168.${splitIpv4[2]}.2$m', 22),
          username: 'usuario',
          onPasswordRequest: () => 'senha',
        );
        await client.run('shutdown -P +1');
        client.close();
      }
    } else if (function == 'a') {
      for (String m in manList()) {
        print('Reiniciando Acrux no PDV: $m');
        final client = SSHClient(
          await SSHSocket.connect('192.168.${splitIpv4[2]}.2$m', 22),
          username: 'usuario',
          onPasswordRequest: () => 'senha',
        );
        print('Matando o Acrux');
        await client.run('killall AcruxPDV');
        print('"killall AcruxPDV" executado com sucesso!');
        sleep(const Duration(seconds: 10));
        print('Tentando abrir o Acrux');
        await client.run('acruxpdv.sh &');
        print('"nohup acruxpdv.sh" executado com sucesso!');
        sleep(const Duration(seconds: 5));
        print('Finalizando conexão!');
        client.close();
      }
    } else if (function == 'c') {
      break;
    } else {
      print('ERRO: Função desconhecida');
    }
  }

  print('Fim do Código!');

}

/* ----------  FUNCTIONS  ---------- */

String? simpleInput() {
  String? userinput = stdin.readLineSync();
  return userinput?.toLowerCase();
}

List<String> simpleSplit({required String? fullString, String? splitBy = '.'}) {
  List<String> splitString = fullString!.split(splitBy!);
  return splitString;
}

List<dynamic> manList() {
  String inst = 'Digite os numeros dos PDVs e digite "f" para finalizar, "c" para\n'
      'fazer uma correção em um pdv adicionado e "v" para ver a lista'
      '\n';
  print(inst);
  List<dynamic> userList = [];
  while (true) {
    String? input = simpleInput();
    if (input == 'f') {
      break;
    } else if(input == 'c') {
      print('Qual elemento na lista\n'
          'você deseja remover?');
      String? inputc = simpleInput();
      userList.remove(inputc);
    } else if (input == 'v') {
      print("Lista atual: $userList");
    } else {
      userList.add(input);
    }
  }
  return userList;
}

class Pdvs {
  String loja;
  List<String> pdv;
  List<String> mac;


  Pdvs({
    required this.loja,
    required this.pdv,
    required this.mac
  });
}
