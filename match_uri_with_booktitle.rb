require 'csv'
require 'json'

# ## 使用说明
# 1. 请将应用的json文件命名为books.json。删除interestedBOoks这个键名。
# 2. 请将csv存为utf8格式并命名为books.csv
# 3. 将上面两个文件放到和 match_uri_with_booktitle.rb 同一个目录。
# 4. 运行 ruby match_uri_with_booktitle.rb
# 5. 该目录中会生成new_db.json文件。就是更新后的books.json。

# ## json文件
# json文件中又按级别分成了几个小数组，对我们没用
# 扁平化，方便遍历
#
# 格式举例
#
#         {
#             "bookName": "苔丝",
#             "booUrl": "#none",
#             "bookImg": "/zhilangnew/css/report/personal/images/book/112450101.jpg"
#         }, {
#             "bookName": "傲慢与偏见",
#             "booUrl": "#none",
#             "bookImg": "/zhilangnew/css/report/personal/images/book/111780101.jpg"
#         },

# ## csv文件
# csv文件第一行是header
#
#         ["推荐书目名称", "访问地址", nil, nil]
#
# 文件中第一列是图书命名，第二列是url。
#
# 只处理那些第二列不为空的。
#
# 为空的说明本次无需更新json。
#
# **json的键名是字符串，不是symbol。**

# 命名空间呗
module MatchURIwithBookTitle

  module_function

  @books = [] # 判断结果是否有错误
  def main(input1 = 'books.json', input2 = 'books.csv', output = 'new_db.json')
    db = read_json(input1)
    csv = load_csv(input2)
    db.each do |e|
      csv.each do |c|
        if e['bookName'] == c[0]
          e['booUrl'] = c[1]
          puts "修改了 #{e['bookName']}"
          @books << e['bookName']
        end
      end
    end
    File.write(output, JSON.pretty_generate(db))
    puts "\n\n\n下面的书可能有问题。因为它们出现在@books中的次数是奇数。\n====="
    puts @books.group_by { |e| e }.select { |k, v| v.length.odd?}.keys
    puts "\n\n\n请查看#{output}文件。\n\n\n"
  end

  def read_json(input)
    JSON.parse(File.read(input)).flatten
  end

  def load_csv(input)
    r = CSV.read(input).select { |e| /^http:/ =~ e[1] }
    r.map { |e| e[0] }.each { |e| @books << e }
    r
  end
end

MatchURIwithBookTitle.main
