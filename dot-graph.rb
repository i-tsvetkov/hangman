def connect(a, b)
  "#{a}\s->\s#{b};"
end

def get_counter
  i = 0
  lambda { i = i.succ }
end

@ctr = get_counter

def mknode(label)
  "{n#{@ctr.call}[label=\"#{label}\"]}"
end

def mkpattern(ps, let, len)
  p = '_' * len
  ps.each { |i| p[i] = let }
  return p
end

def get_graph(tree, wsize, pnode = nil)
  graph = []
  unless pnode.nil?
    if tree.key?(:letter)
      lnode = mknode(tree[:letter])
      graph.push connect(pnode, lnode)
    else
      graph.push connect(pnode, "{\s#{tree[:words].join("\s")}\s}")
      return graph
    end
  end

  lnode ||= mknode(tree[:letter])

  tree[:tree].each do |ps, t|
    pn = mknode(mkpattern(ps, tree[:letter], wsize))
    graph.push connect(lnode, pn)
    graph += get_graph(t, wsize, pn)
  end

  return graph
end

