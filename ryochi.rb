#!/usr/bin/ruby

# �M���h : guild
#   �̒n���͍ő�8�̃M���h���Q������
# �̒n : realm
#   �e�̒n�͍ő�1�̃I�[�i�[�M���h������
# �}�b�` : match
#   �}�b�`�͗̒n�Ŏ��{�����
#   �}�b�`�ɂ�2�̃M���h���Q������
#   ���ɃI�[�i�[������̒n�Ń}�b�`����������ꍇ�A
#   �}�b�`�ɎQ������M���h�̂�������̓I�[�i�[�ƂȂ�
# ���D : bid
#   �e�M���h�͍ő�2�̓��D���\
#   ���D��1�̗̒n��1�̌�����������
#   �������̍����ق����珇�ɏ��������
#
# ���D�̐���
#   �ȉ������ׂĖ��������ꍇ�ɓ��D�����ƂȂ�A
#   ���D�ɏ]�����}�b�`���J�Â����B
#   - ���D���s�����M���h���Q�����Ă���}�b�`��1�ȉ��ł���
#   - ���D�Ώۂ̗̒n�Ń}�b�`���������Ă��Ȃ�
#   ���D���s�����ꍇ�A���̓��D�͖����ƂȂ�A
#   ���������_�̓��D�����������
#
# �}�b�`���O�ɂ���
#   - ���D���s�����̒n�ɃI�[�i�[�����݂���ꍇ�A
#     ���D���s�����M���h�ƃI�[�i�[�M���h���}�b�`�ɎQ������
#   - ���D���s�����M���h�ɃI�[�i�[�����݂��Ȃ��ꍇ�A
#     ���D���s���M���h���b��I�[�i�[�ƂȂ�

GUILD_SIZE = 8
REALM_SIZE = 16
REALM_EXISTED_OWNER_SIZE = 14

guilds = [*1..GUILD_SIZE].map{ |i| "g#{i}" }

# �̒n�̏����I�[�i�[��ݒ�B
# �Ƃ肠�����u5�̒n���[���v�ɂ��Ă͖ڂ��Ԃ邱�Ƃɂ���
realms = Hash.new([])
[*1..REALM_SIZE].each{ |i|
  realms.store("r#{i}", i <= REALM_EXISTED_OWNER_SIZE ? guilds.sample : nil)
}

# ���D�����B��������1�ȏ�10000�ȉ��Ń����_���B
# ������Ƃ��͓K���Ƀ\�[�g
bid = Struct.new("Bid", :guild, :realm, :price)
bids = Array.new
guilds.each{ |g|
  realms_biddable = realms.select{ |k,v| v != g }.keys
  realms_biddable.sample(2).each{ |r|
    bids.push(bid.new(g, r, rand(1..10000)))
  }
}
bids.sort_by!{ |b| b.price }.reverse!

# ���D���ɏ������āA�}�b�`���쐬
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
#   �{���Ȃ�2�}�b�`�ɒB���ĂȂ��M���h���A
#   2�}�b�`�Q���ł���悤�ɗ]��̃}�b�`���쐬���鏈��������

puts "----"

# �m�F
guilds.each{ |g|
  matches_for_guild = matches.select{ |m| ((m.guild1 == g) || (m.guild2 == g)) }
  puts "guild:#{g} : match count is #{matches_for_guild.count}"
  matches_for_guild.each { |m| puts "  g1:#{m.guild1}, g2:#{m.guild2}, r:#{m.realm}" }
}


#p guilds
#p realms
#p bids
#p matches
