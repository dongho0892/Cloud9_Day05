require 'sinatra'
require 'csv'
# require 'sinatra/reloader'

get'/'do
 erb :index
end

get '/new' do
    erb :new
end


post '/create' do

    # 사용자가 입력한 정보를 받아서 
    # CSV 파일 가장 마지막에 등록
    # => 이 글의 글번호도 같이 저장해야함.
    # => 기존의 글 개수를 파악해서
    #    그 글 갯수 + 1 해서 저장.
    
    title = params[:title] # 변수에 저장
    contents = params[:contents]
                                # w+ : 읽고, 쓰고 / 기존에 있는 파일을 지워버림.
#   id = CSV.read('./boards.csv', 'w+').count.to_i + 1  # CSV.open 과 유사함. / 읽기모드로 갯수를 셈.
    id = CSV.read('./boards.csv').size + 1  # CSV.open 과 유사함. / 읽기모드로 갯수를 셈.
    
    puts [id,title,contents]   # 아이디가 제대로 출력되는지 확인
    
    CSV.open('./boards.csv', 'a+') do |row|    # 각 줄에 우리가 작성한 id, title, contents 넣어주고.
        row << [id, title, contents]                # 어떤 모드가 더 좋은지 파악 해볼것! 
    end
#   redirect '/boards'
    redirect "/board/#{id}"
end




get '/boards' do

    # 파일을 읽기 모드로 열고
    # 각 줄을 순회하면서
    # @가 붙어있는 변수에 넣어줌.

    @boards = []                                  # 1
    CSV.open('./boards.csv', 'r').each do |row|   # 2  현재 폴더에 있는 csv 파일을 열겠다.
        @boards << row        
    end
    puts @boards
    erb :boards
end


get '/board/:id' do             # boards/글번호   => 와일드 카드로 사용!
    # CSV 파일에서 params[:id]로 넘어온 친구와 
    # 같은 글번호를 가진 row를 선택
    # => CSV 파일을 전체 순회한다.
    # => 순회하다가 첫번째 column이 id와 같은 값을 만나면
    # => 순회를 정지하고, 값을 변수에다가 담아준다.

    @board=[]
    CSV.read('./boards.csv').each do |row| # 각각 돌면서 row에 담아준다.
        if row[0].eql?(params[:id])   # 만약 row의 0번째가 파라미터로 넘어온 것과 같아진다면
  #     if params[:id]==row[0]

            @board = row
            break           # 그 값을 board에 넣어주고, 멈춘다.
        end
    end
    puts @board
    erb :board
end



#######################################

get '/user/new' do
    erb :new_user
end

post '/user/create' do
    
    puts params[:id], params[:password], params[:password_confirmation]
    if params[:password].eql?(params[:password_confirmation])
        users= []
        file = CSV.read('./users.csv','r+')
        file.each do |row|
            users << row[1]
        end
        puts file
        unless users.include?(params[:id])
            index = file.size + 1
        
    # 정상적인 가입 로직
        
            id = params[:id]
            password = params[:password]
    
        # if params[:password] != params[:password_confirmation]
        #     puts "비밀번호가 옳바르지 않습니다."
        #     erb :new_user
        # else
        #     erb :index
        # end

            CSV.open('./users.csv', 'a+') do |row|    # 각 줄에 우리가 작성한 id, title, contents 넣어주고.
                row << [index, id, password]                # 어떤 모드가 더 좋은지 파악 해볼것! 
            end
            redirect "/user/#{index}"
        else
            erb :error
        end
    else
    # error.erb 파일에는 회원가입에 실패했습니다. 메시지 띄우기.
        erb :error
    end
end


get '/users' do
    @users =[]
    CSV.open('./users.csv','r+').each do |row|
        @users << row
    end
    puts @users
    erb :users
end

get '/user/:id' do
    @user = []
    CSV.open('./users.csv', 'r+').each do |row|
        if row[0].eql?(params[:id])
            @user = row
            break
        end
    end
    erb :user
end