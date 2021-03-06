module MessageStore
  module Postgres
    module Get
      class Stream
        class Last
          include MessageStore::Get::Stream::Last

          dependency :session, Session

          def configure(session: nil)
            Session.configure(self, session: session)
          end

          def call(stream_name)
            logger.trace(tag: :get) { "Getting last message data (Stream Name: #{stream_name})" }

            result = get_result(stream_name)

            return nil if result.nil?

            message_data = convert(result[0])

            logger.info(tag: :get) { "Finished getting message data (Stream Name: #{stream_name})" }
            logger.info(tags: [:data, :message_data]) { message_data.pretty_inspect }

            message_data
          end

          def get_result(stream_name)
            logger.trace(tag: :get) { "Getting last record (Stream: #{stream_name})" }

            sql_command = self.class.sql_command(stream_name)

            parameter_values = [
              stream_name
            ]

            result = session.execute(sql_command, parameter_values)

            logger.debug(tag: :get) { "Finished getting result (Count: #{result.ntuples}, Stream: #{stream_name}" }

            return nil if result.ntuples == 0

            result
          end

          def self.sql_command(stream_name)
            parameters = '$1::varchar'

            "SELECT * FROM get_last_stream_message(#{parameters});"
          end

          def convert(record)
            logger.trace(tag: :get) { "Converting record to message data" }

            message_data = Get.message_data(record)

            logger.debug(tag: :get) { "Converted record to message data" }

            message_data
          end
        end
      end
    end
  end
end
