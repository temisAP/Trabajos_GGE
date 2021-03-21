  function H = mtitle(ax,l1,l2)
  % MTITLE places a two-line title on the figure.
  %
  % MTITLE(L1,L2) place a two-line title on the
  % plot.  L1 is the first line, L2 is the second.
  %
  % MTITLE(AX,L1,L2) places the title above the
  % axes AX.  AX is the handle to the axes.

  % John L. Galenski III
  % Copyright by The MathWorks, Inc.  1994

  if nargin ~= 2
    error('MTITLE requires 2 inputs.')
  end
  if nargin == 2
    l2 = l1;
    l1 = ax;
    ax = gca;
  end
  axes(ax)

  % Determine the location of the title
  title(' ')
  T = get(ax,'Title');
  Tu = get(T,'Units');
  set(T,'Units','normal')
  PT = get(T,'Extent');
  set(T,'Units',Tu)
  X = PT(1);
  Y = PT(2);
  H = PT(4);

  % Place the titles
  h = text('Units','normal','Position',[X,Y+H,0], ...
      'Clipping','off','VerticalAlignment','bottom', ...
      'HorizontalAlignment','center','String',l1);

  h(2) = text('Units','normal','Position',[X,Y+H,0], ...
      'Clipping','off','VerticalAlignment','top', ...
      'HorizontalAlignment','center','String',l2);

  if nargout == 1
    H = h;
  end