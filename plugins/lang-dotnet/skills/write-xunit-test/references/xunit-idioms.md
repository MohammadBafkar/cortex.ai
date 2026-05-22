# xUnit idiom reference

Quick reference for xUnit patterns used by `lang-dotnet.write-xunit-test`.

## Parametrized cases

Use `[Theory]` + `[InlineData]` (not multiple `[Fact]` methods) when only inputs vary:

```csharp
[Theory]
[InlineData(1, 2, 3)]
[InlineData(0, 0, 0)]
[InlineData(-1, 1, 0)]
public void Add_TwoOperands_ReturnsSum(int a, int b, int expected)
{
    Assert.Equal(expected, Add(a, b));
}
```

For complex case data, use `[MemberData(nameof(SomeMethod))]` returning `IEnumerable<object[]>`.

## Shared setup

`IClassFixture<T>` shares one instance across all tests in a class — perfect for an expensive setup that needs to happen once:

```csharp
public class DatabaseTests : IClassFixture<TestDatabase>
{
    private readonly TestDatabase _db;
    public DatabaseTests(TestDatabase db) => _db = db;
}
```

Avoid `[Fact]`-level setup via a constructor unless the setup is truly cheap — xUnit instantiates the class once per test.

## Async exceptions

`Assert.ThrowsAsync<T>` returns the exception so you can assert on its message/properties:

```csharp
var ex = await Assert.ThrowsAsync<InvalidOperationException>(
    () => sut.LoadAsync("missing.txt"));
Assert.Contains("not found", ex.Message);
```

Don't wrap in try/catch + `Assert.True(false)` — that's an anti-pattern.

## Mocks

Pick one of Moq or NSubstitute per project. Don't mix.

Moq:
```csharp
var repo = new Mock<IUserRepository>();
repo.Setup(r => r.FindAsync(1)).ReturnsAsync(new User(1, "Alice"));
var sut = new UserService(repo.Object);
```

NSubstitute:
```csharp
var repo = Substitute.For<IUserRepository>();
repo.FindAsync(1).Returns(new User(1, "Alice"));
var sut = new UserService(repo);
```

## FluentAssertions (when project uses it)

```csharp
user.Should().NotBeNull();
user.Id.Should().Be(1);
user.Name.Should().StartWith("Al");
```

Reads as English; failure messages name the property being asserted.

## What NOT to do

- `[Fact(Skip = "...")]` without a real reason — name the unmet precondition.
- `[Theory]` with no `[InlineData]` / `[MemberData]` — the test has no inputs to vary.
- `Thread.Sleep(...)` in tests — use `Task.Delay` with cancellation or restructure.
- `Assert.True(...)` for non-boolean conditions — use the typed assertion that names the failure (`Assert.Equal`, `Assert.NotNull`, etc.).
- Mixing Moq and NSubstitute in the same project — pick one.
