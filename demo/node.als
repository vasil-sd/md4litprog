sig Node {
  prev: Node,
  next: Node
}
fact valid {
  all N : Node | -- для всех узлов выполняется:
    N.prev.next = N -- следующий у предыдущего указывает на текущий
    and N.next.prev = N -- предыдущий у следующего указывает на текущий
}
pred is_cyclic[n:Node] {
  n in n.^Node.next -- ^Node.next - транзитивное замыкание
                    -- получаем отношение всех достижимых узлов
                    -- n.^Node.next - все узлы достижимые из n
}
