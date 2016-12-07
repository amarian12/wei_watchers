module SpecHelpers
  def ethereum_txid
    "0x#{SecureRandom.hex(32)}"
  end

  def ethereum_address
    "0x#{SecureRandom.hex(20)}"
  end

  def ethereum_gas_price
    "0x#{SecureRandom.hex(5)}"
  end

  def ethereum_create_transaction_response(options = {})
    options.with_indifferent_access
    {
      "id" => (options[:id] || HttpClient.random_id),
      "jsonrpc" => "2.0",
      "result" => (options[:result] || options[:txid] || ethereum_txid)
    }
  end

  def ethereum_receipt_response(options = {})
    options.with_indifferent_access
    hashie({
      id: 7357,
      jsonrpc: '2.0',
      result: {
        blockHash: ethereum_txid,
        blockNumber: '0x7357',
        contractAddress: (options[:contract_address] || ethereum_address),
        cumulativeGasUsed: ethereum_gas_price,
        gasUsed: ethereum_gas_price,
        logs: [{}],
        transactionHash: (options[:txid] || options[:transaction_hash] || ethereum_txid),
        transactionIndex:  '0x1',
      }
    })
  end

  def ethereum_contract_factory(options = {})
    EthereumContract.create({
      account: options[:account],
      address: options[:address],
      template: options[:template],
    })
  end

  def ethereum_oracle_factory(options = {})
    oracle_contract_factory.terms.first.expectation.tap do |oracle|
      oracle.ethereum_contract = ethereum_contract_factory
      oracle.update_attributes options
    end
  end

  def ethereum
    @ethereum ||= EthereumClient.new
  end

  def wait_for_ethereum_confirmation(txid)
    average_block_time = 17
    try_rate = 4.0
    buffer = 3

    receipt = nil
    ((average_block_time * buffer) * try_rate).to_i.times do
      block_height = ethereum.current_block_height
      receipt ||= ethereum.get_transaction_receipt(txid)

      if receipt && receipt.blockNumber
        tx_block_number ||= ethereum.hex_to_int(receipt.blockNumber)
        break if (tx_block_number && (block_height.to_i >= tx_block_number.to_i))
      end
      sleep (1 / try_rate)
    end
  end
end
