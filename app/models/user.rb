class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    has_many :bookings
    has_many :check_ins
    has_many :meeting_participants, dependent: :destroy
    has_many :participated_bookings, through: :meeting_participants, source: :booking

    has_one_attached :avatar

    # Validations
    validates :username, presence: true,
                        uniqueness: { case_sensitive: false },
                        length: { minimum: 3, maximum: 20 },
                        format: { with: /\A[a-zA-Z0-9_]+\z/, message: "สามารถใช้ได้เฉพาะตัวอักษร ตัวเลข และ _ เท่านั้น" }

    validates :email, presence: true,
                     uniqueness: { case_sensitive: false },
                     format: { with: URI::MailTo::EMAIL_REGEXP, message: "รูปแบบอีเมลไม่ถูกต้อง" }

    validate :password_complexity
    validate :avatar_size

    # Scopes
    scope :exclude_user, ->(user) { where.not(id: user.id) }

    private

    def password_complexity
      return if password.blank? || password =~ /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$/

      errors.add :password, "ต้องมีอย่างน้อย 8 ตัวอักษร และต้องประกอบด้วยตัวพิมพ์เล็ก (a-z), ตัวพิมพ์ใหญ่ (A-Z), และตัวเลข (0-9)"
    end

    def avatar_size
      return unless avatar.attached?

      if avatar.blob.byte_size > 5.megabytes
        errors.add(:avatar, "ขนาดไฟล์ต้องไม่เกิน 5MB")
      end
    end
end
