#include <sol/sol.hpp>

int main() {
	sol::state lua;
	lua.open_libraries(sol::lib::base);
	lua.script("print('hello world')");
	return 0;
}
