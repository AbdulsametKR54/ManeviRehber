using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCategoryIdToDailyContent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "CategoryId",
                table: "DailyContents",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_DailyContents_CategoryId",
                table: "DailyContents",
                column: "CategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_DailyContents_Categories_CategoryId",
                table: "DailyContents",
                column: "CategoryId",
                principalTable: "Categories",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DailyContents_Categories_CategoryId",
                table: "DailyContents");

            migrationBuilder.DropIndex(
                name: "IX_DailyContents_CategoryId",
                table: "DailyContents");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "DailyContents");
        }
    }
}
