using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveCategoryIdAndAddSpecialDayAndCategories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DailyContents_Categories_CategoryId",
                table: "DailyContents");

            migrationBuilder.RenameColumn(
                name: "CategoryId",
                table: "DailyContents",
                newName: "SpecialDayId");

            migrationBuilder.RenameIndex(
                name: "IX_DailyContents_CategoryId",
                table: "DailyContents",
                newName: "IX_DailyContents_SpecialDayId");

            migrationBuilder.CreateTable(
                name: "DailyContentCategories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    DailyContentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    CategoryId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DailyContentCategories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DailyContentCategories_Categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "Categories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DailyContentCategories_DailyContents_DailyContentId",
                        column: x => x.DailyContentId,
                        principalTable: "DailyContents",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DailyContentCategories_CategoryId",
                table: "DailyContentCategories",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_DailyContentCategories_DailyContentId",
                table: "DailyContentCategories",
                column: "DailyContentId");

            migrationBuilder.AddForeignKey(
                name: "FK_DailyContents_SpecialDays_SpecialDayId",
                table: "DailyContents",
                column: "SpecialDayId",
                principalTable: "SpecialDays",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DailyContents_SpecialDays_SpecialDayId",
                table: "DailyContents");

            migrationBuilder.DropTable(
                name: "DailyContentCategories");

            migrationBuilder.RenameColumn(
                name: "SpecialDayId",
                table: "DailyContents",
                newName: "CategoryId");

            migrationBuilder.RenameIndex(
                name: "IX_DailyContents_SpecialDayId",
                table: "DailyContents",
                newName: "IX_DailyContents_CategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_DailyContents_Categories_CategoryId",
                table: "DailyContents",
                column: "CategoryId",
                principalTable: "Categories",
                principalColumn: "Id");
        }
    }
}
