﻿# -*- coding: utf-8 -*-
require "set"
require "psbot/target"

module PSBot
  # This class represents a room, and includes methods to interact
  # with the room.
  class Room < Target
    include PSBot::Helpers

    # This is included to avoid the spamming of +PSBot::Utilities::Deprecation+.
    include PSBot::Utilities

    # @return [String]
    attr_reader :name

    # Users are stored as a Hash mapping a User to their auth
    # level in the room.
    #
    # @return [Hash{User => String}] all users in the room
    attr_reader :users

    def initialize(name, bot)
      @bot    = bot
      @name   = name
      @users  = Hash.new {|h, k| h[k] = []}
      @in_room = false
    end

    # @group Checks

    # @param [User] user
    # @return [Boolean] true if the user is in the room
    def has_user?(user)
      @users.has_key? user
    end

    # @return [Array<String>] all users in the room
    def user_array
      user_arr = []
      @users.keys.zip(@users.values).each do |user, auth|
        user_arr << auth + user.name
      end
      user_arr
    end

    # @endgroup

    # @group User groups

    # Get the authority level of a user in the room. Return `nil`
    # if the user is not in the room.
    #
    # @param [User] A User
    # @return [String, nil] The authority level of the user
    def auth(user)
      return nil if !has_user?(user)
      @users[user]
    end

    # Returns all of the users with the specified rank within
    # the room.
    #
    # @param [String] group The target group
    # @return [Array<User>, nil] All users with the target group
    #   in the room. Returns +nil+ if the group doesn't exist.
    def all_auth(group)
      return nil unless AUTH_STRINGS.has_key? group
      @users.select {|_, auth| auth == group}.keys
    end

    # @return [Array<User>] All admins in the room
    def admins
      Deprecation.print_deprecation("0.2.0", "Room#admins", 'Room#all_auth("~")')
      all_auth("~")
    end

    # @return [Array<User>] All owners in the room
    def owners
      Deprecation.print_deprecation("0.2.0", "Room#owners", 'Room#all_auth("#")')
      all_auth("#")
    end

    # @return [Array<User>] All mods in the room
    def moderators
      Deprecation.print_deprecation("0.2.0", "Room#moderators", 'Room#all_auth("@")')
      all_auth("@")
    end

    # @return [Array<User>] All drivers in the room
    def drivers
      Deprecation.print_deprecation("0.2.0", "Room#drivers", 'Room#all_auth("%")')
      all_auth("%")
    end

    # @return [Array<User>] All voiced users in the room
    def voiced
      Deprecation.print_deprecation("0.2.0", "Room#voiced", 'Room#all_auth("+")')
      all_auth("+")
    end

    # @return [Array<User>] All unvoiced users in the room
    def unvoiced
      Deprecation.print_deprecation("0.2.0", "Room#unvoiced", 'Room#all_auth(" ")')
      all_auth(" ")
    end

    # @return [Array<User>] All muted users in the room
    def muted
      Deprecation.print_deprecation("0.2.0", "Room#muted", 'Room#all_auth("!")')
      all_auth("!")
    end

    # @return [Array<User>] All locked users in the room
    def locked
      Deprecation.print_deprecation("0.2.0", "Room#locked", 'Room#all_auth("‽")')
      all_auth("‽")
    end
    # @endgroup

    # @group Room Manipulation

    # Joins the room
    #
    # @return [void]
    def join
      @bot.connection.send "|/join #{@name}"
      @in_room = true
    end

    # Leaves the room
    #
    # @param [String] reason An optional parting message
    # @return [void]
    def leave(reason = nil)
      @bot.connection.send "#{@name}|#{reason}" if reason
      @bot.connection.send "|/leave #{@name}"
      @in_room = false
    end

    # @endgroup

    # Add a user to the room.
    #
    # @api private
    # @param [User] user
    # @param [String] auth The user's auth level in this room
    # @return [User] The added user
    def add_user(user, auth)
      @in_room = true if user == @bot
      @users[user] = auth
      user
    end

    # Remove a user from the room.
    #
    # @api private
    # @param [User] user
    # @return [User, nil] The removed user
    def remove_user(user)
      @in_room = false if user == @bot
      @users.delete(user)
    end
 
    # Set the modchat in the room
    #
    # @param [String] level
    # @return [void]
    def set_modchat(level)
      send "/modchat #{level}"
    end

    # Remove all users
    #
    # @api private
    # @return [Hash{User => String}] the empty hash
    def clear_users
      @users.clear
    end

    # Send a message to this room.
    def send(text)
      super("#{@name}|#{text.to_s}")
    end

    # @return [Fixnum]
    def hash
      @name.hash
    end

    # @return [String]
    def to_s
      @name
    end

    # @return [String]
    def inspect
      "#<Room name=#{@name.inspect}>"
    end
  end
end
