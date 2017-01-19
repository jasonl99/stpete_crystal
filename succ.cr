names = %w(bob jason sam bob_01 bob_02 bob_03 bob_04 bob_05 bob_06 bob_07 bob_08 bob_09)
new_name = "bob"
new_name = "bob_01" if names.index(new_name)
while names.index(new_name)
  new_name = new_name.succ
end
puts new_name
