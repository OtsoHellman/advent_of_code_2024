import aoc_2024/utils/listx
import aoc_2024/utils/resultx
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import glearray

pub fn pt_1(input: String) {
  let disk =
    input
    |> string.split("")
    |> list.sized_chunk(2)
    |> list.map(fn(pair) {
      let pair = pair |> list.map(resultx.int_parse_unwrap)
      case pair {
        [a, b] -> #(a, b)
        [a] -> #(a, 0)
        _ -> panic
      }
    })
    |> listx.zip_with_index
    |> list.flat_map(fn(o) {
      let #(#(file_space, free_space), i) = o
      let file = i |> list.repeat(file_space) |> list.map(int.to_string)
      let free = "." |> list.repeat(free_space)
      [file, free] |> list.flatten
    })

  let empty_indices =
    disk
    |> listx.find_indices(fn(o) { o == "." })

  let disk_array = glearray.from_list(disk)

  let compacted_disk =
    update_disk_1(
      disk_array,
      empty_indices,
      glearray.length(disk_array) - 1,
      glearray.length(disk_array) - list.length(empty_indices),
    )

  let filtered_disk =
    compacted_disk
    |> glearray.to_list
    |> list.filter(fn(a) { a != "." })
    |> listx.zip_with_index

  use sum, #(block, i) <- list.fold(filtered_disk, 0)

  sum + { resultx.int_parse_unwrap(block) * i }
}

fn update_disk_1(
  disk: glearray.Array(String),
  empty_indices: List(Int),
  i: Int,
  max: Int,
) -> glearray.Array(String) {
  use <- bool.guard(empty_indices |> list.is_empty, disk)
  use <- bool.guard(i < max, disk)

  let block = disk |> glearray.get(i) |> resultx.assert_unwrap

  case block {
    "." -> update_disk_1(disk, empty_indices, i - 1, max)
    _ -> {
      let #(empty_i, empty_indices) = empty_indices |> listx.pop()
      let disk =
        disk
        |> glearray.copy_set(empty_i, block)
        |> resultx.assert_unwrap
        |> glearray.copy_set(i, ".")
        |> resultx.assert_unwrap

      update_disk_1(disk, empty_indices, i - 1, max)
    }
  }
}

// value, size, starting_index
type DiskEntry =
  #(Int, Int, Int)

type Disk =
  glearray.Array(DiskEntry)

pub fn pt_2(input: String) {
  let disk =
    parse_disk_2(input)
    |> fn(a) { a.0 }

  let blocks = disk |> list.filter(fn(a) { 0 <= a.0 })
  let spaces = disk |> list.filter(fn(a) { a.0 < 0 }) |> list.reverse

  let disk =
    update_disk(
      glearray.from_list(blocks),
      glearray.from_list(spaces),
      list.length(blocks) - 1,
      list.length(spaces) - 1,
      0,
    )
    |> combine_disks

  use sum, #(block, i) <- list.fold(listx.zip_with_index(disk), 0)

  case block > 0 {
    True -> sum + { block * i }
    False -> sum
  }
}

fn update_disk(
  blocks: Disk,
  spaces: Disk,
  blocks_length: Int,
  spaces_length: Int,
  block_i: Int,
) -> #(Disk, Disk) {
  use <- bool.guard(blocks_length <= block_i, #(blocks, spaces))

  let #(block, spaces) =
    blocks
    |> glearray.get(block_i)
    |> resultx.assert_unwrap
    |> update_block(spaces, spaces_length, 0)

  let blocks =
    blocks |> glearray.copy_set(block_i, block) |> resultx.assert_unwrap

  update_disk(blocks, spaces, blocks_length, spaces_length, block_i + 1)
}

fn update_block(
  block: DiskEntry,
  spaces: Disk,
  spaces_length: Int,
  space_i: Int,
) -> #(DiskEntry, Disk) {
  use <- bool.guard(spaces_length <= space_i, #(block, spaces))

  let space = spaces |> glearray.get(space_i) |> resultx.assert_unwrap
  use <- bool.guard(block.2 < space.2, #(block, spaces))

  case block.1 <= space.1 {
    True -> {
      let updated_block = #(block.0, block.1, space.2)
      let updated_space = #(space.0, space.1 - block.1, space.2 + block.1)
      let new_space = #(space.0, block.1, block.2)

      let spaces =
        spaces
        |> glearray.copy_set(space_i, updated_space)
        |> result.map(glearray.copy_push(_, new_space))
        |> resultx.assert_unwrap

      #(updated_block, spaces)
    }
    False -> update_block(block, spaces, spaces_length, space_i + 1)
  }
}

fn combine_disks(disks: #(Disk, Disk)) {
  let #(blocks, spaces) = disks

  [blocks, spaces]
  |> list.flat_map(glearray.to_list)
  |> list.sort(fn(a, b) { int.compare(a.2, b.2) })
  |> list.flat_map(disk_entry_to_list)
}

fn disk_entry_to_list(disk_entry: DiskEntry) {
  let #(value, size, _) = disk_entry
  list.repeat(value, size)
}

fn parse_disk_2(input: String) {
  let input =
    input
    |> string.split("")
    |> list.map(resultx.int_parse_unwrap)
    |> listx.zip_with_index

  use #(entries, block_i, arr_i), #(value, i) <- list.fold(input, #(
    list.new(),
    0,
    0,
  ))

  let is_block = { int.modulo(i, 2) |> resultx.assert_unwrap } == 0

  case is_block {
    True -> #(
      list.prepend(entries, #(block_i, value, arr_i)),
      block_i + 1,
      arr_i + value,
    )
    False -> #(
      list.prepend(entries, #(-1, value, arr_i)),
      block_i,
      arr_i + value,
    )
  }
}
