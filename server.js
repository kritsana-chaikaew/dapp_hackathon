#!/usr/bin/env node

const Web3 = require('web3');
const solc = require('solc');
const fs = require('fs');
const http = require('http');
const {sha3withsize} = require('solidity-sha3');

const provider = new Web3.providers.HttpProvider("http://localhost:8545")
const web3 = new Web3(provider);
const asciiToHex = Web3.utils.asciiToHex;

const turnLength = '10';
const p1Commitment = sha3withsize(3, 8);

async function main () {
  const accounts = await web3.eth.getAccounts();
  const opponent = accounts[1];
  console.log(accounts);

  const code = fs.readFileSync('./TicTacToe.sol').toString();
  const compiledCode = solc.compile(code);
  const byteCode = compiledCode.contracts[':TicTacToe'].bytecode;
  const abiDefinition = JSON.parse(
    compiledCode.contracts[':TicTacToe'].interface);
  console.log('abiDefinition', abiDefinition);

  const TicTacToeContract = new web3.eth.Contract(
    abiDefinition, {data: byteCode, from: accounts[0], gas: 4700000});

  const deployedContract = await TicTacToeContract.deploy({
    arguments: [opponent, turnLength, p1Commitment]
  }).send();
  console.log('deployedContract', deployedContract);
}

main();