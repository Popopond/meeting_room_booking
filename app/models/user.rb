class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable  
    has_many :bookings
    has_many :check_ins
    has_many :meeting_participants, dependent: :destroy
    has_many :participated_bookings, through: :meeting_participants, source: :booking
  
    validates :username, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    # Scopes
    scope :exclude_user, ->(user) { where.not(id: user.id) }
  end
  