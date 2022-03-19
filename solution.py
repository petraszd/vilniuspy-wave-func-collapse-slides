import random

FROM_TOP_TO_BOTTOM = 1
FROM_BOTTOM_TO_TOP = 2
FROM_RIGHT_TO_LEFT = 4
FROM_LEFT_TO_RIGHT = 8

def wfc_solve(
        num_cols,
        num_rows,
        num_fragments,
        compatibilities,
):
    def pick_unselected():
        unselected = []
        for (x, y), idx in selections.items():
            if idx is False:
                unselected.append((x, y))
        if not unselected:
            return None
        return random.choice(unselected)

    def pick_fragment(x, y):
        availabilities = all_availabilities[(x, y)]
        fragments = []
        for i, is_available in enumerate(availabilities):
            if is_available:
                fragments.append(i)
        if not fragments:
            return None
        return random.choice(fragments)

    def update_neighbours_availabilities(x0, y0):
        neighbours = [
            (x0, y0 + 1, FROM_TOP_TO_BOTTOM),
            (x0, y0 - 1, FROM_BOTTOM_TO_TOP),
            (x0 - 1, y0, FROM_RIGHT_TO_LEFT),
            (x0 + 1, y0, FROM_LEFT_TO_RIGHT),
        ]
        for x1, y1, dir in neighbours:
            if (x1, y1) not in selections:
                continue
            if update_availabilities(x0, y0, x1, y1, dir) > 0:
                update_neighbours_availabilities(x1, y1)

    def update_availabilities(x0, y0, x1, y1, dir):
        if selections[(x1, y1)] is True:
            return 0

        from_fragments = [
            idx for idx, is_available in
            enumerate(all_availabilities[(x0, y0)])
            if is_available
        ]
        to_fragments = [
            idx for idx, is_available in
            enumerate(all_availabilities[(x1, y1)])
            if is_available
        ]

        num_udpated = 0
        for to_idx in to_fragments:
            is_compatible = False
            for from_idx in from_fragments:
                comp_idx = from_idx * num_fragments + to_idx
                comp = compatibilities[comp_idx]
                if comp & dir > 0:
                    is_compatible = True
                    break
            if not is_compatible:
                num_udpated += 1
                all_availabilities[(x1, y1)][to_idx] = False

        return num_udpated

    selections = {}
    all_availabilities = {}
    for y in range(num_rows):
        for x in range(num_cols):
            selections[(x, y)] = False
            all_availabilities[(x, y)] = [True] * num_fragments

    while True:
        tile = pick_unselected()
        if tile is None:
            break
        x, y = tile
        idx = pick_fragment(x, y)
        if idx is None:
            break
        yield x, y, idx
        selections[(x, y)] = True
        all_availabilities[(x, y)] = [False] * num_fragments
        all_availabilities[(x, y)][idx] = True
        update_neighbours_availabilities(x, y)
