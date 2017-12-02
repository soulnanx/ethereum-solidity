pragma solidity ^0.4.16;

contract Owned {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Owned() public {
    owner = msg.sender;
  }

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier isNotOwner() {
    require(msg.sender != owner);
    _;
  }
  
  function changeOwner(address _newOwner) public isOwner {
    OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
 
}

contract Destroyer is Owned {
    
  function destroy() isOwner public {
    selfdestruct(owner);
  }
  
}

contract Registro {

  mapping(address => address) private registro;
  address[] public contas;

  event EventoRegistro(address _contaPessoa, address _contaContratoPessoa, bool _inserido, string _nome);

  function novoContrato (address _pessoa, address _contrato, string _nome) public {
    if (registro[msg.sender] == 0x0) {
      contas.push(_pessoa);
      registro[_pessoa] = _contrato;
      EventoRegistro(_pessoa, _contrato, true, _nome);
    } else {
      EventoRegistro(_pessoa, _contrato, false, _nome);
      revert();
    }
  }

  function getContrato() public view returns(address) {
    return registro[msg.sender];
  }

  function tamanho () public view returns (uint) {
    return contas.length;
  }

}

contract Pessoa is Destroyer {

  string public nome;
  string public cpf;
  string public email;
  bool public cpfValido;
  uint256 public dataNascimento;
  address registroContrato;
  address[] public validadores;
  uint8 public validacoes;

  event LogEmailAlterado(string indexed _previousEmail, string indexed _newEmail);
  event LogValidado(address indexed _validador);

  function Pessoa (string _nome, string _cpf, uint256 _dataNascimento, address _registro) public {
    nome = _nome;
    cpf = _cpf;
    dataNascimento = _dataNascimento;
    registroContrato = _registro;
    Registro registro = Registro(_registro);
    if (registro.tamanho() == 0) {
        validacoes++;
    }
	registro.novoContrato(msg.sender, this, _nome);
  }

  function mudaEmail (string _novoEmail) public isOwner {
    email = _novoEmail;
    LogEmailAlterado(email, _novoEmail);
  }

  function validar() external isNotOwner {
    Registro registro = Registro(registroContrato);
    Pessoa pessoa = Pessoa(registro.getContrato());
    require(pessoa.retornaValidacoes() > 0);
    validadores.push(msg.sender);
    validacoes += 1;
    LogValidado(msg.sender);
  }
  function retornaValidacoes() public view returns (uint8) {
    return validacoes;
  }
}