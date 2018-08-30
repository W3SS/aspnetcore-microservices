using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Kubernetes.POCS.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args)
        {
            var secretsPath = Path.Combine(Directory.GetCurrentDirectory(), "secrets");
            return WebHost.CreateDefaultBuilder(args)
                .UseHealthChecks("/hc")
                .ConfigureAppConfiguration(builder =>
                {
                    builder
                        .AddYamlFile("configs/appSettings", true)
                        .AddKeyPerFile(secretsPath, true);
                })
                .UseStartup<Startup>();
        }
    }
}
