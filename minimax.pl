:- module(minimax,
        [ minimax/5            % The minimax algorithm
        ]).

:- use_module(board,
        [ moves/3,
          other_player/2
        ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%     Minimax
%%%
%%%
%%%     This is a minimax algorithm using alpha-beta pruning
%%%
%%%         minimax(+Board, +ToMove, -[Z,Y,X], -NextBoard, +Depth)
%%%
%%%         where Board is the current board state
%%%               ToMove is the current player piece kind (x/o)
%%%               BestMove is the best selected move
%%%               NextBoard is the next board state (after move)
%%%               Depth is the analysis depth (must be > 0)
%%%
%%%         if there is no more moves available, it fails

minimax(Board, ToMove, BestMove, NextBoard, Depth) :-
  Depth > 0,
  alphabeta(Board, ToMove, 0, 1000000, node(BestMove,NextBoard,_), 0, Depth).

alphabeta(node(_,_,Val), _, _, _, Val, 0) :- !.

alphabeta(Board, ToMove, Alpha, Beta, GoodBoard, Val, Depth) :-
  board:moves(Board, ToMove, NextBoards),
  OneDeeper is Depth - 1,
  boundedbest(NextBoards, Alpha, Beta, ToMove, OneDeeper, GoodBoard, Val).

boundedbest([Board|TailBoards], Alpha, Beta, ToMove, Depth, GoodBoard, GoodVal) :-
  board:other_player(ToMove, Other),
  alphabeta(Board, Other, Alpha, Beta, Depth, _, Val),
  goodenough(TailBoards, Alpha, Beta, ToMove, Board, Val, GoodBoard, GoodVal).

goodenough([], _, _, _, Board, Val, Board, Val) :- !.   % No other candidate

goodenough(_, Alpha, Beta, ToMove, Board, Val, Board, Val) :-
  min_to_move(ToMove), Val > Beta, !                 % Maximizer attained upper bound
  ;
  max_to_move(ToMove), Val < Alpha, !.               % Minimizer attained lower bound

goodenough(BoardList, Alpha, Beta, ToMove, Board, Val, GoodBoard, GoodVal)  :-
  newbounds(Alpha, Beta, ToMove, Val, NewAlpha, NewBeta),    % Refine bounds  
  boundedbest(BoardList, NewAlpha, NewBeta, Board1, Val1),
  betterof(ToMove, Board, Val, Board1, Val1, GoodBoard, GoodVal).

newbounds(Alpha, Beta, ToMove, Val, Val, Beta)  :-
  min_to_move(ToMove), Val > Alpha, !.               % Maximizer increased lower bound 

newbounds(Alpha, Beta, ToMove, Val, Alpha, Val)  :-
  max_to_move(ToMove), Val < Beta, !.                % Minimizer decreased upper bound 

newbounds(Alpha, Beta, _, _, Alpha, Beta).           % Otherwise bounds unchanged 

betterof(ToMove, Board1, Val1, _, Val2, Board1, Val1)  :-  % Board1 better than Board2 
  min_to_move(ToMove), Val1 > Val2, !
  ;
  max_to_move(ToMove), Val1 < Val2, !.

betterof(_, _, _, Board2, Val2, Board2, Val2).       % Otherwise Board2 is better

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- begin_tests(minimax).
:- use_module(board, [ empty/1, print_board/1 ]).
:- use_module(moves, [ put/4 ]).

test(should_win) :-
  empty(Em),
  moves:put(Em, [0,0,0], x, B1),
  moves:put(B1, [0,1,0], x, B2),
  moves:put(B2, [0,2,0], x, B3),
  moves:put(B3, [1,0,0], o, B4),
  moves:put(B4, [1,1,0], o, B5),
  moves:put(B5, [1,2,0], o, Board),
  minimax(Board, x, [Z,Y,X], _, 4),
  nl, format('Move: ~d/~d/~d.', [Z,Y,X]), nl,
  [Z,Y,X] = [0,3,0].

:- end_tests(minimax).

