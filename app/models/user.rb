class User < ActiveRecord::Base
  TEMP_EMAIL = 'change@me.com'
  TEMP_EMAIL_REGEX = /change@me.com/

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, #:confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
      user = User.where(:provider => auth.provider, :uid => auth.uid).first
      if user
        return user
      else
        registered_user = User.where(:email => auth.info.email).first
        if registered_user
          return registered_user
        else
          user = User.create(name:auth.extra.raw_info.name,
                              provider:auth.provider,
                              uid:auth.uid,
                              email:auth.info.email,
                              token:auth.credentials.token,
                              password:Devise.friendly_token[0,20],
                            )
        end
      end
    end


    def facebook
      @facebook ||= Koala::Facebook::API.new(token)
      block_given? ? yield(@facebook) : @facebook
      rescue Koala::Facebook::APIError => e
      logger.info e.to_s
      nil # or consider a custom null object
    end

    def permission
       facebook { |fb| fb.get_connection("me", "permissions") }
    end
    def friends_count
      facebook { |fb| fb.get_connection("me", "friends").size }
    end
    def get_likes
        facebook { |fb| fb.get_connection("me", "likes") }
    end

     def friendslist
          facebook { |fb| fb.get_connections("me", "mutualfriends/1185412440") }
      end

      def subsc
        facebook {|fb| fb.get_connections("me","list_subscriptions" )}
      end

      def mefault
        #fresh = .search("so fresh")
        facebook {|fb| fb.get_connections("me","family")}
       #facebook.sort_by do |a| a.relationship end
      end

      def posts
        facebook {|fb| fb.get_connections("me","feed")}
      end

      def status
        facebook {|fb| fb.get_connections("me","status")}
      end

      def postit
        facebook.put_wall_post("testing for dups")
      end

      def remove_post
        #facebook.delete_object("100008308419358_1383538691933065")
        facebook.delete_object("443393035756312","Dollface")
        redirect_to :back
      end

      def getpic(pin)
        facebook.get_object(pin)
      end
end