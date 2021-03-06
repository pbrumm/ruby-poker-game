# coding: UTF-8
require File.expand_path("../test_helper", File.dirname(__FILE__))

# This integration test verifies that when the cards are dealt, and no player
# folds, the player with the best hand wins.
#
# The deck of cards is 'rigged' to get testable results.
#
# As an example for three players, the order of cards in a deck are:
#   [p1, p2, p3, p1, p2, p3, b1, f, f, f, b2, t, b3, r]
# Where:
#  pX = card for a player (p2, p3, etc)
#  bX = burn
#  f  = flop
#  t  = turn
##  r  = river
class DealingTest < ActiveSupport::TestCase

  test "a rigged deck should deal as expected" do
    rigged_cards = [
      5.H, 9.S, J.D, 
      6.H, T.S, J.S, 2.H, 
      8.C, 7.S, 3.S, 3.H, 
      9.D, 4.S, 
      J.C
    ]
    
    Deck.any_instance.stubs(:take_card).returns(*rigged_cards)
    table = Table.new

    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down table
    paul.sit_down table
    george.sit_down table

    # assert dealt cards
    table.deal
    assert_equal Hole.new([5.H, 6.H]), john.hole
    assert_equal Hole.new([9.S, T.S]), paul.hole
    assert_equal Hole.new([J.D, J.S]), george.hole

    # assert flop cards
    table.deal_flop
    assert_equal [8.C, 7.S, 3.S], table.board.cards

    # assert turn card
    table.deal_turn
    assert_equal 9.D, table.board.cards.last

    # assert river card
    table.deal_river
    assert_equal J.C, table.board.cards.last
  end

  test "rigging the deck should deal cards to expected players straight/straight/three-of-a-kind" do
    rigged_cards = [
      5.H, 9.S, J.D, 
      6.H, T.S, J.S, 2.H, 
      8.C, 7.S, 3.S, 3.H, 
      9.D, 4.S, 
      J.C
    ]
    Deck.any_instance.stubs(:take_card).returns(*rigged_cards)
    table = Table.new

    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down table
    paul.sit_down table
    george.sit_down table

    table.deal
    table.deal_flop
    table.deal_turn
    table.deal_river

    # assert winner (the highest straight)
    winners = table.winners
    assert_equal paul, winners.first

    # assert hands
    assert john.hand.kind_of? Straight
    assert paul.hand.kind_of? Straight
    assert george.hand.kind_of? ThreeOfAKind
  end

end