// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "../CARNEGIETOKEN/carnegietoken.sol";

contract Carnegie {

    //-------------------------------- DECLARACIONES INICIALES --------------------------

    CarnegieTSC private Token;
    address payable public Owner;

    constructor () public {
        Token = new CarnegieTSC(10000000);          // cantidad de monedas que se van a crear 10.000.000
        Owner = msg.sender;                         // msg.sender es el user que despliega el SmartContract
    }

   
    struct client {                                 // Estructura de datos para almacenar los clientes de Carnegie
        uint tokens;
    }

    mapping (address => client) public Clients;     // Mapping para el registro de clientes

    struct course {                                 // Estructura de datos para almacenar los cursos de Carnegie
        string name;
        uint price;
        bool enabled;
    }

    string [] Courses;

    mapping (string => course) public MappingCourses;   // Mapping para el registro de cursos

    //-------------------------------- GESTION DE TOKENS --------------------------------

    function PriceTokens(uint _numTokens) internal pure returns (uint) {
        return _numTokens*(0.001 ether);
    }

    function BuyTokens(uint _numTokens) public payable {
      
        uint cost = PriceTokens(_numTokens);                                          // Establecer el precio de los Tokens
        require (msg.value >= cost, "Buy less Tokens or pay with more ethers");       // El cliente tiene saldo para comprar Tokens?
        uint returnValue = msg.value - cost;                                          // Diferencia o vuelto de lo que el cliente paga
        msg.sender.transfer(returnValue);                                             // Disney retorna la cantidad de ethers al cliente
        uint Balance = TotalBalance();                                                // Obtencion del numero de tokens disponibles
        require (_numTokens <= Balance, "Buy a smaller number of Tokens");

        Token.transfer(msg.sender, _numTokens);                                       // Se tranfiere el numero de tokens al cliente
        Clients[msg.sender].tokens += _numTokens;                                     // Registro de tokens comprados
    }

    function TotalBalance() public view returns (uint) {
        return Token.balanceOf(address(this));
    }

    function MyTokens() public view returns (uint) {
        return Token.balanceOf(msg.sender);
    }

    function GenerateTokens(uint _numTokens) public Unicamente(msg.sender) {
        return Token.increaseTotalSupply(_numTokens);
    }

    modifier Unicamente(address _address) {
        require(_address == Owner, "You do not have permissions to execute this function.");
        _;
    }

    //-------------------------------- GESTION DE CARNEGIE ------------------------------

    event create_course(string, uint);
    event delete_course(string);

    function CreateCourse(string memory _courseName, uint _price) public Unicamente (msg.sender) {
        MappingCourses[_courseName] = course(_courseName, _price, true);
        // Courses.push(_courseName);
        emit create_course(_courseName, _price);
    }

    function DeleteCourse(string memory _courseName) public Unicamente (msg.sender) {
        MappingCourses[_courseName].enabled = false;
        emit delete_course(_courseName);
    }


     function AllCourses() public view returns (string [] memory) {
        return Courses;
    }

    function BuyCourse(string memory _courseName) public {
        uint coursePrice = MappingCourses[_courseName].price;
        require(coursePrice <= MyTokens(), "You need more token to buy this course");
        Token.transferToCarnegie(msg.sender, address(this), coursePrice);
        Clients[msg.sender].tokens -= coursePrice;
    }

}