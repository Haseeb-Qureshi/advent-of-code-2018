class LinkedList
  attr_accessor :head, :tail

  include Enumerable
  def initialize
    @head = nil
    @tail = nil
  end

  def append(val)
    if @head.nil?
      @tail = @head = Link.new(val)
    else
      new_link = Link.new(val, nil, @tail)
      @tail.next = new_link
      @tail = new_link
    end
  end

  def append_to(link, val)
    new_link = link.append(val)

    @tail = new_link if link == @tail

    new_link
  end

  def seek(link, i)
    return link if i == 0

    if i < 0
      return seek(link.prev, i + 1) if link.prev
      seek(@tail, i + 1)
    else # i > 0
      return seek(link.next, i - 1) if link.next
      seek(@head, i - 1)
    end
  end

  def delete_and_get_next(link)
    if link == @head
      @head = link.next
      @head.prev = nil
      @head
    elsif link == @tail
      @tail = link.prev
      @tail.next = nil
      @head
    else
      link.prev.next = link.next
      link.next.prev = link.prev
      link.next
    end
  end

  def each
    return if @head.nil?

    curr = @head
    while curr
      yield curr
      curr = curr.next
    end
  end

  def to_s
    map(&:itself).inspect
  end

  def inspect
    to_s
  end
end

class Link
  attr_accessor :val, :next, :prev

  def initialize(val, subsequent = nil, prev = nil)
    @val = val
    @next = subsequent
    @prev = prev
  end

  def append(val)
    link = Link.new(val, nil, self)
    @next.prev = link if @next
    link.next = @next
    @next = link

    link
  end

  def to_s
    s = ""
    s += "~~" if @prev
    s += @val.to_s
    s += "~~" if @next
    s
  end

  def inspect
    to_s
  end
end
