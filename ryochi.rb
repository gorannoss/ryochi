#!/usr/bin/ruby

# ギルド : guild
#   領地線は最大8つのギルドが参加する
# 領地 : realm
#   各領地は最大1つのオーナーギルドを持つ
# マッチ : match
#   マッチは領地で実施される
#   マッチには2つのギルドが参加する
#   既にオーナーがいる領地でマッチが発生する場合、
#   マッチに参加するギルドのうち一方はオーナーとなる
# 入札 : bid
#   各ギルドは最大2つの入札が可能
#   入札は1つの領地と1つの権利金を持つ
#   権利金の高いほうから順に処理される
#
# 入札の成否
#   以下をすべて満たした場合に入札成功となり、
#   入札に従ったマッチが開催される。
#   - 入札を行ったギルドが参加しているマッチが1つ以下である
#   - 入札対象の領地でマッチが発生していない
#   入札失敗した場合、その入札は無効となり、
#   権利金次点の入札が処理される
#
# マッチングについて
#   - 入札を行った領地にオーナーが存在する場合、
#     入札を行ったギルドとオーナーギルドがマッチに参加する
#   - 入札を行ったギルドにオーナーが存在しない場合、
#     入札を行たギルドが暫定オーナーとなる

GUILD_SIZE = 8
REALM_SIZE = 16
REALM_EXISTED_OWNER_SIZE = 14

guilds = [*1..GUILD_SIZE].map{ |i| "g#{i}" }

# 領地の初期オーナーを設定。
# とりあえず「5領地ルール」については目をつぶることにする
realms = Hash.new([])
[*1..REALM_SIZE].each{ |i|
  realms.store("r#{i}", i <= REALM_EXISTED_OWNER_SIZE ? guilds.sample : nil)
}

# 入札を作る。権利金は1以上10000以下でランダム。
# 被ったときは適当にソート
bid = Struct.new("Bid", :guild, :realm, :price)
bids = Array.new
guilds.each{ |g|
  realms_biddable = realms.select{ |k,v| v != g }.keys
  realms_biddable.sample(2).each{ |r|
    bids.push(bid.new(g, r, rand(1..10000)))
  }
}
bids.sort_by!{ |b| b.price }.reverse!

# 入札順に処理して、マッチを作成
match = Struct.new("Match", :guild1, :guild2, :realm)
matches = Array.new
bids.each_with_index{ |bid, i|
  print "bid #{i} ... guild:#{bid.guild}, realm:#{bid.realm}   "
  matches_count = matches.sum{ |m| (((m.guild1 == bid.guild) || (m.guild2 == bid.guild)) ? 1 : 0) }
  if matches_count >= 2 then
    puts "fail (the guild is already entried 2 match)"
    next
  end
  if matches.any?{ |m| m.realm == bid.realm }
    puts "fail (the realm is already existed in matches)"
    next
  end

  puts "OK"
  owner = realms[bid.realm]
  if owner then
    matches.push(match.new(bid.guild, owner, bid.realm))
  else
    second_guild = nil
    if second = bids[i+1..-1].find{ |sb| sb.realm == bid.realm } then
      second_guild = second.guild
    end
    matches.push(match.new(bid.guild, second_guild, bid.realm))
  end
}

# TODO :
#   本来なら2マッチに達してないギルドが、
#   2マッチ参加できるように余剰のマッチを作成する処理がある

puts "----"

# 確認
guilds.each{ |g|
  matches_for_guild = matches.select{ |m| ((m.guild1 == g) || (m.guild2 == g)) }
  puts "guild:#{g} : match count is #{matches_for_guild.count}"
  matches_for_guild.each { |m| puts "  g1:#{m.guild1}, g2:#{m.guild2}, r:#{m.realm}" }
}


#p guilds
#p realms
#p bids
#p matches
