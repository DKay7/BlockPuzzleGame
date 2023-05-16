#include <cmath>
#include <cstddef>
#include <cstdlib>
#include <tuple>
#include <vector>
#include <iostream>
#include <set>
#include <queue>

template <typename underlying_linear_container>
class proxy2d {
public:
    proxy2d(underlying_linear_container &container,
            size_t col_len, size_t col_index):
        container_(container),
        row_index_(col_index), col_len_(col_len) {}

    decltype(auto) operator[](std::size_t col_index) {
        return container_[row_index_ * col_len_ + col_index];
    }

private:
    underlying_linear_container &container_;
    size_t row_index_, col_len_;
};


template <typename underlying_linear_container>
class wrap2d {
public:
    wrap2d(underlying_linear_container &&container, size_t col_len):
        col_len_(col_len), container_(std::move(container)) {}

    proxy2d<std::vector<bool>> operator[](std::size_t row_index) {
        return { container_, col_len_, row_index };
    }

    size_t col_length() { return col_len_; }
    size_t row_length() { return container_.size() / col_len_; }

private:
    size_t col_len_;
    underlying_linear_container container_;
};


class bitset2d: private wrap2d<std::vector<bool>> {
public:
    using wrap2d<std::vector<bool>>::operator[];

    using wrap2d<std::vector<bool>>::col_length;
    using wrap2d<std::vector<bool>>::row_length;

    bitset2d(size_t row_len, size_t col_len):
        wrap2d(std::vector<bool>(row_len * col_len), col_len) {}
};

enum directions { up, down, right, left };
struct color { int r, g, b; };

class tile {
public:
    tile(size_t x, size_t y, size_t width, size_t height, color color):
        x_(x), y_(y), width_(width), height_(height), color_(color) {}

    std::vector<tile>& possible_movements(bitset2d &freeze) const {
        bool possibilities[] = { 1, 1, 1, 1 };

        static std::vector<tile> tiles = {};
        tiles.clear();

        for (size_t j = x_; j < x_ + width_; ++ j)
            possibilities[up]    &= y_ + height_ < freeze.row_length() && !freeze[y_ + height_][j];

        if (possibilities[up])
            tiles.emplace_back(x_, y_ + 1, width_, height_, color_);

        for (size_t j = x_; j < x_ + width_; ++ j)
            possibilities[down]  &= y_           >= 1                  && !freeze[y_ - 1][j];

        if (possibilities[down])
            tiles.emplace_back(x_, y_ - 1, width_, height_, color_);

        for (size_t i = y_; i < y_ + height_; ++ i)
            possibilities[right] &= x_ + width_  < freeze.col_length() && !freeze[i][x_ + width_];

        if (possibilities[right])
            tiles.emplace_back(x_ + 1, y_, width_, height_, color_);

        for (size_t i = y_; i < y_ + height_; ++ i)
            possibilities[left]  &= x_           >= 1                  && !freeze[i][x_ - 1];

        if (possibilities[left])
            tiles.emplace_back(x_ - 1, y_, width_, height_, color_);

        return tiles;
    }

    void fill(bitset2d &freeze, size_t bit) const {
        for (size_t i = x_; i < x_ + width_; ++ i)
            for (size_t j = y_; j < y_ + height_; ++ j)
                freeze[j][i] = bit;
    }

    auto operator<=>(const tile& other) const {
        return std::tie(x_, y_, width_, height_) <=> std::tie(other.x_, other.y_, other.width_, other.height_);
    }

    size_t x_, y_;
    size_t width_, height_;

    color color_;
};

class board {
public:
    board(std::set<tile> tiles, size_t width, size_t height):
        freeze_(width, height), tiles_(tiles) {

        for (auto &&tile: tiles_)
            tile.fill(freeze_, 1);
    }

    std::vector<board> get_possible_successors() {
        std::vector<board> possible_successors;

        for (auto &&tile: tiles_) {
            auto &tiles = tile.possible_movements(freeze_);
            for (auto &&movement: tiles) {
                std::set<::tile> new_tiles = tiles_;

                // preserve tile color:
                movement.color_ = tile.color_;
                new_tiles.erase(tile);

                new_tiles.insert(movement);
                possible_successors.emplace_back(std::move(new_tiles),
                    freeze_.row_length(), freeze_.col_length());
            }
        }

        return possible_successors;
    }

    std::set<tile> &tiles() { return tiles_; }

    double get_dist() const {
        const int init_x = 2;
        const int init_y = 2;

        double dist1 = 0;
        for (auto &&tile: tiles_) 
            if (tile.height_ == 2 && tile.width_ == 2) {
                dist1 = std::pow(tile.x_ - init_x, 2.0f) + std::pow(tile.y_ - init_y, 2.0f);
                break;
            }

        return dist1;
    }

    auto operator<=>(const board &other) const {
        const int init_x = 2, init_y = 2;

        double dist1 = get_dist();
        double dist2 = other.get_dist();

        return std::tie(dist1, tiles_) <=> std::tie(dist2, other.tiles_);
    }

    void print_serialized() {
        for (auto &tile: tiles_) {
            std::cout << tile.x_       << " " << tile.y_ << " "
                      << tile.width_   << " "
                      << tile.height_  << " "
                      << tile.color_.r << " "
                      << tile.color_.g << " "
                      << tile.color_.b << "; ";
        }

        std::cout << std::endl;
    }

private:
    bitset2d freeze_;
    std::set<tile> tiles_;
};

std::set<board> generate_derivative_boards(board source) {
    std::set<board> visited;

    std::priority_queue<board> staged;
    staged.push(source);

    int count = 0;
    while (!staged.empty()) {
        auto current_board = staged.top();
        staged.pop();

        visited.insert(current_board);

        for (auto &&board: current_board.get_possible_successors())
            if (!visited.contains(board))
                staged.push(board);

        if (++ count > 200000) // We don't need that many
            break;
    }

    return visited;
}

int main() {
    std::set<tile> tiles = {
        tile(0, 0, 2, 1, { 109, 126, 182 }),
        tile(2, 0, 1, 2, { 109, 126, 182 }),
        tile(0, 4, 2, 1, { 109, 126, 182 }),
        tile(2, 4, 2, 1, { 109, 126, 182 }),

        tile(2, 2, 2, 2, { 205, 181, 109 }),

        tile(0, 2, 1, 1, {   6,  42, 139 }),
        tile(0, 3, 1, 1, {   6,  42, 139 }),
        tile(1, 2, 1, 1, {   6,  42, 139 }),
        tile(1, 3, 1, 1, {   6,  42, 139 }),
    };

    board won_position(std::move(tiles), 5, 4);
    auto derivatives_set = generate_derivative_boards(won_position);

    std::vector derivatives(derivatives_set.begin(), derivatives_set.end());

    std::srand(time(0));
    auto chosen_one = derivatives[rand() % derivatives.size()];

    chosen_one.print_serialized();
}
