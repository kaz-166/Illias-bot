class ApplicationController < ActionController::Base
    # [Security!] CSRF攻撃これで大丈夫？？要調査
    protect_from_forgery with: :null_session
end
