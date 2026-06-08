# frozen_string_literal: true

require "digest/md5"
require "base64"

module ActiveStorage
  class Service::PostgresqlService < Service
    def upload(key, io, checksum: nil, **)
      instrument :upload, key: key, checksum: checksum do
        data = io.read
        ensure_integrity!(data, checksum) if checksum

        record = ActiveStorageDbFile.find_or_initialize_by(key: key)
        record.data = data
        record.save!
      end
    end

    def download(key, &block)
      data = instrument :download, key: key do
        ActiveStorageDbFile.find_by!(key: key).data
      end
      raise ActiveStorage::FileNotFoundError if data.nil?

      if block_given?
        instrument :streaming_download, key: key do
          yield data
        end
      else
        data
      end
    rescue ActiveRecord::RecordNotFound
      raise ActiveStorage::FileNotFoundError
    end

    def download_chunk(key, range)
      instrument :download_chunk, key: key, range: range do
        download(key).byteslice(range)
      end
    end

    def delete(key)
      instrument :delete, key: key do
        ActiveStorageDbFile.where(key: key).delete_all
      end
    end

    def delete_prefixed(prefix)
      instrument :delete_prefixed, prefix: prefix do
        ActiveStorageDbFile.where("key LIKE ?", "#{sanitize_like(prefix)}%").delete_all
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = ActiveStorageDbFile.exists?(key: key)
        payload[:exist] = answer
        answer
      end
    end

    private

    def ensure_integrity!(data, checksum)
      return if Base64.strict_encode64(Digest::MD5.digest(data)) == checksum

      raise ActiveStorage::IntegrityError
    end

    def sanitize_like(prefix)
      ActiveRecord::Base.sanitize_sql_like(prefix)
    end
  end
end
