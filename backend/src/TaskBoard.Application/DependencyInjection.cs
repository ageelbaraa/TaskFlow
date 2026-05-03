using FluentValidation;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using TaskBoard.Application.Common.Behaviours;

namespace TaskBoard.Application;

/// <summary>Registers Application-layer services into the DI container.</summary>
public static class DependencyInjection
{
    /// <summary>
    /// Adds MediatR handlers, FluentValidation validators, and pipeline behaviours
    /// from the Application assembly.
    /// </summary>
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly);
        });

        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly);

        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));

        return services;
    }
}
