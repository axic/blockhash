//
// Blockhash contract (EIP210) implementation in Yul
//
//
//

{
  // Reject incoming value transfers
//  jumpi(unpaid, iszero(callvalue()))
//  invalid
//  unpaid:

  let cur_block_number := number()
  let offset := 0

  switch caller()
    case 0xfffffffffffffffffffffffffffffffffffffffe {
    // Sender is the system account - Setting a block
    let pn := sub(cur_block_number, 1)
    let block_hash := calldataload(0)

    for {} 1 {} {
      let bn256 := mod(bn, 256)

      sstore(add(offset, bn256), block_hash)

      switch bn256
        case 0 {}
        default { stop() }

      bn := div(bn, 256)
      offset := add(offset, 256)
    }
  }

  default {
    // Sender is a regular account - Getting a block
    let block_number := calldataload(0)

    switch slt(block_number, cur_block_number)
      case 0: { return(0) }
      default: {
        let dist_minus_one := sub(sub(cur_block_number, block_number), 1)

        for { } and(gte(dist_minus_one, 256), eq(mod(block_number, 256) == 0)) {} {
          offset := add(offset, 256)
          block_number := div(block_number, 256)
          dist_minus_one := div(dist_minus_one, 256)
        }

        switch gte(dist_minus_one, 256)
          case 0: { return(0) }

        return(sload(add(offset, mod(block_number, 256))))
      }
  }
}