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
    let bn := sub(cur_block_number, 1)
    let block_hash := calldataload(0)

    for {} 1 {} {
      let bn256 := mod(bn, 256)

      sstore(add(offset, bn256), block_hash)

      // if not zero
      if bn256 { return(0, 0) }

      bn := div(bn, 256)
      offset := add(offset, 256)
    }
  }

  default {
    // Sender is a regular account - Getting a block
    let block_number := calldataload(0)

    if iszero(slt(block_number, cur_block_number)) { return(0, 0) }

    let dist_minus_one := sub(sub(cur_block_number, block_number), 1)

    for { } and(gte(dist_minus_one, 256), eq(mod(block_number, 256), 0)) {} {
      offset := add(offset, 256)
      block_number := div(block_number, 256)
      dist_minus_one := div(dist_minus_one, 256)
    }

    if iszero(gte(dist_minus_one, 256)) { return(0, 0) }

    mstore(0, sload(add(offset, mod(block_number, 256))))
    return(0, 32)
  }
}
