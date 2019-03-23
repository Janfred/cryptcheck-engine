require 'socket'

class BasicSocket < IO
	def recvmsg(*args, **kwargs)
		timeout = kwargs.delete :timeout
		begin
			self.recvmsg_nonblock *args, **kwargs
		rescue IO::WaitReadable
			IO.select [self], nil, nil, timeout
			retry
		end
	end

	def sendmsg(*args, **kwargs)
		timeout = kwargs.delete :timeout
		begin
			self.sendmsg_nonblock *args, **kwargs
		rescue Errno::EINPROGRESS
			IO.select nil, [self], nil, timeout
			retry
		end
	end

	{
			uint8:  [1, 'C'],
			uint16: [2, 'S>'],
			uint32: [4, 'L>'],
			uint64: [8, 'Q>'],

			int8:   [1, 'c'],
			int16:  [2, 's>'],
			int32:  [4, 'l>'],
			int64:  [8, 'q>'],
	}.each do |name, config|
		size, type = config
		class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
			def recv_#{name}(*args, **kwargs)
				data = self.recvmsg #{size}, *args, **kwargs
				data.unpack('#{type}').first
			end

			def send_#{name}(value, *args, **kwargs)
				data = [value].pack '#{type}'
				self.sendmsg data, *args, **kwargs
			end
		RUBY_EVAL
	end
end
